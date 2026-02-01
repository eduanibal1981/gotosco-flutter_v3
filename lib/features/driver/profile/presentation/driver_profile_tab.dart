// lib/features/driver/profile/presentation/driver_profile_tab.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gotosco_v3/features/auth/data/auth_repository.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:gotosco_v3/core/providers/user_session_provider.dart';
import 'package:gotosco_v3/core/widgets/map_picker_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../data/driver_profile_repository.dart';
import 'widgets/coverage_summary_content.dart';
import '../data/driver_profile_model.dart';
import '../data/driver_schedule_model.dart';
import '../../dashboard/data/driver_dashboard_repository.dart';
import 'controllers/driver_profile_scroll_controller.dart';

class DriverProfileTab extends ConsumerStatefulWidget {
  const DriverProfileTab({super.key});

  @override
  ConsumerState<DriverProfileTab> createState() => _DriverProfileTabState();
}

class _DriverProfileTabState extends ConsumerState<DriverProfileTab> {
  final _scrollController = ScrollController();
  final _serviceAreasKey = GlobalKey();
  final _locationSettingsKey = GlobalKey();
  String? _expandedShiftType;
  String? _currentLocationText;
  double? _currentLocationLat;
  double? _currentLocationLng;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentDriverProfileProvider);

    ref.listen<DriverProfileScrollTarget?>(
      driverProfileScrollTargetControllerProvider,
      (previous, next) {
        if (next == null) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToTarget(next);
        });
        ref
            .read(driverProfileScrollTargetControllerProvider.notifier)
            .setTarget(null);
      },
    );

    return profileAsync.when(
      data: (profile) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: profile != null ? _buildAppBar(profile) : null,
          body: profile == null
              ? _buildNoProfileState()
              : _buildProfileContent(profile),
        );
      },
      loading: () => Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Center(child: Text('Error: $err')),
      ),
    );
  }

  void _scrollToTarget(DriverProfileScrollTarget target) {
    final contextToScroll = switch (target) {
      DriverProfileScrollTarget.serviceAreas => _serviceAreasKey.currentContext,
      DriverProfileScrollTarget.locationSettings =>
        _locationSettingsKey.currentContext,
    };
    if (contextToScroll == null) return;
    Scrollable.ensureVisible(
      contextToScroll,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.1,
    );
  }

  PreferredSizeWidget _buildAppBar(DriverProfileModel profile) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Profile',
        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      actions: [
        _buildVerificationBadge(profile),
        IconButton(
          onPressed: () => _showEditProfileSheet(profile),
          icon: const Icon(Icons.edit, color: Colors.black87),
          tooltip: 'Edit Profile',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildVerificationBadge(DriverProfileModel profile) {
    final status = profile.verificationStatus;

    String label;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case VerificationStatus.verified:
        label = 'Verified';
        backgroundColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        icon = Icons.verified;
        break;
      case VerificationStatus.pending:
        label = 'Pending';
        backgroundColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        icon = Icons.schedule;
        break;
      case VerificationStatus.unverified:
        label = 'Unverified';
        backgroundColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        icon = Icons.warning_amber_rounded;
        break;
    }

    return GestureDetector(
      onTap: () => _showVerificationInfo(status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: textColor.withOpacity(0.3),
            width: status == VerificationStatus.unverified ? 1.5 : 1,
          ),
          boxShadow: status == VerificationStatus.unverified
              ? [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (status == VerificationStatus.unverified) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.touch_app,
                size: 14,
                color: textColor.withOpacity(0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showVerificationInfo(VerificationStatus status) {
    String title;
    String message;
    IconData icon;
    Color iconColor;

    switch (status) {
      case VerificationStatus.verified:
        title = 'Verified Driver';
        message =
            'Your account has been verified by the GoToSco team. You can now receive booking requests from parents.';
        icon = Icons.verified;
        iconColor = Colors.green;
        break;
      case VerificationStatus.pending:
        title = 'Verification Pending';
        message =
            'Your documents have been submitted and are currently under review by the GoToSco team. You\'ll be notified once the verification is complete.';
        icon = Icons.schedule;
        iconColor = Colors.orange;
        break;
      case VerificationStatus.unverified:
        title = 'Upload Required Documents';
        message =
            'Please upload your driver\'s license and vehicle mulkia (registration) to get verified. These documents will only be reviewed by the GoToSco team and are required to start accepting bookings.';
        icon = Icons.warning_amber_rounded;
        iconColor = Colors.orange.shade700;
        break;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfileState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Driver Profile',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete your profile to start receiving booking requests.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showCreateProfileSheet(),
              icon: const Icon(Icons.add),
              label: const Text('Create Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(DriverProfileModel profile) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header with profile photo and name
        SliverToBoxAdapter(child: _buildHeader(profile)),

        // Content sections
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              // Driver Information Section
              _buildSection(
                icon: Icons.person,
                title: 'Driver Information',
                children: [
                  _buildInfoRow('Name', profile.name),
                  _buildInfoRow(
                    'Experience',
                    '${profile.experienceYears} years',
                  ),
                  _buildInfoRow(
                    'License No',
                    profile.licenseNumber ?? 'Not set',
                  ),
                  _buildInfoRow(
                    'License Expires',
                    profile.licenseExpiry != null
                        ? DateFormat(
                            'dd/MM/yyyy',
                          ).format(profile.licenseExpiry!)
                        : 'Not set',
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentUploadRow(
                    label: 'Upload License for Verification',
                    hint: 'Only reviewed by GoToSco Team',
                    currentUrl: profile.licenseImageUrl,
                    onUpload: () => _handleDocumentUpload(profile, 'license'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Vehicle Details Section
              _buildSection(
                icon: Icons.directions_bus,
                title: 'Vehicle Details',
                children: [
                  _buildInfoRow('Type', profile.vehicleType),
                  _buildInfoRow('Number', profile.vehicleNumber ?? 'Not set'),
                  _buildInfoRow(
                    'Capacity',
                    '${profile.vehicleCapacity} children',
                  ),
                  const SizedBox(height: 12),
                  _buildDocumentUploadRow(
                    label: 'Upload Car Mulkia',
                    hint: 'Vehicle registration document',
                    currentUrl: profile.mulkiaImageUrl,
                    onUpload: () => _handleDocumentUpload(profile, 'mulkia'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Pricing Section
              _buildSection(
                icon: Icons.attach_money,
                title: 'Pricing',
                children: [
                  _buildPriceRow('Monthly Two-way', profile.priceMonthlyTwoWay),
                  _buildPriceRow('Monthly One-way', profile.priceMonthlyOneWay),
                  _buildPriceRow('Daily', profile.priceDaily),
                ],
              ),

              const SizedBox(height: 16),

              // Bio Section
              _buildSection(
                icon: Icons.description,
                title: 'Bio',
                children: [
                  Text(
                    profile.bio.isNotEmpty
                        ? profile.bio
                        : 'No bio added yet. Tell parents about yourself!',
                    style: TextStyle(
                      color: profile.bio.isNotEmpty
                          ? Colors.grey.shade800
                          : Colors.grey.shade500,
                      fontSize: 14,
                      fontStyle: profile.bio.isEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Location Settings Section
              KeyedSubtree(
                key: _locationSettingsKey,
                child: _buildLocationSettingsSection(profile),
              ),

              const SizedBox(height: 16),

              // Weekly Schedule Section
              _buildScheduleSection(),

              const SizedBox(height: 16),

              // Service Areas Section
              KeyedSubtree(
                key: _serviceAreasKey,
                child: _buildSection(
                  icon: Icons.location_on,
                  title: 'Service Areas & Schools',
                  children: [const CoverageSummaryContent()],
                ),
              ),

              const SizedBox(height: 16),

              // Account Section (Role Switcher)
              Consumer(
                builder: (context, ref, child) {
                  final sessionAsync = ref.watch(userSessionProvider);
                  return sessionAsync.when(
                    data: (session) {
                      if (session == null || !session.isDualRole) {
                        return const SizedBox.shrink();
                      }

                      final otherRole = session.activeRole == 'driver'
                          ? 'parent'
                          : 'driver';
                      final otherRoleName = otherRole == 'driver'
                          ? 'Driver'
                          : 'Parent';

                      return Column(
                        children: [
                          _buildSection(
                            icon: Icons.swap_horiz,
                            title: 'Account',
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await ref
                                      .read(userSessionProvider.notifier)
                                      .switchRole(otherRole);
                                  if (context.mounted) {
                                    context.go(
                                      otherRole == 'driver'
                                          ? '/driver-home'
                                          : '/parent-home',
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Switched to $otherRoleName mode',
                                        ),
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.indigo.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.indigo.shade100,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          otherRole == 'driver'
                                              ? Icons.directions_bus
                                              : Icons.people,
                                          color: Colors.indigo.shade700,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Switch to $otherRoleName Mode',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.indigo.shade800,
                                              ),
                                            ),
                                            Text(
                                              'You have both parent and driver roles',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.indigo.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.chevron_right,
                                        color: Colors.indigo.shade400,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showEditProfileSheet(profile),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Version
              Center(
                child: Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
              ),

              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(DriverProfileModel profile) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade700, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Profile Photo with verification badge
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: profile.photoUrl != null
                    ? NetworkImage(profile.photoUrl!)
                    : null,
                child: profile.photoUrl == null
                    ? Text(
                        profile.name.isNotEmpty
                            ? profile.name[0].toUpperCase()
                            : 'D',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              if (profile.isVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      size: 20,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          // Role Badge + Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_bus,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'DRIVER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade400, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    profile.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' (${profile.totalReviews})',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Email
          Text(
            profile.email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.teal, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Section content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, double price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
          ),
          Text(
            price > 0 ? '\$${price.toStringAsFixed(2)}' : 'Not set',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: price > 0 ? Colors.teal.shade700 : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadRow({
    required String label,
    required String hint,
    required String? currentUrl,
    required VoidCallback onUpload,
  }) {
    final hasDocument = currentUrl != null && currentUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasDocument ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDocument ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: hasDocument
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasDocument ? Icons.check_circle : Icons.upload_file,
              color: hasDocument
                  ? Colors.green.shade700
                  : Colors.orange.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasDocument ? 'Document Uploaded' : label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: hasDocument
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                  ),
                ),
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 12,
                    color: hasDocument
                        ? Colors.green.shade600
                        : Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onUpload,
            child: Text(hasDocument ? 'Replace' : 'Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDocumentUpload(
    DriverProfileModel profile,
    String type,
  ) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        // Show loading snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uploading $type...'),
            duration: const Duration(seconds: 1),
          ),
        );

        final file = File(image.path);
        final url = await ref
            .read(driverProfileRepositoryProvider)
            .uploadDocument(
              driverId: profile.id,
              file: file,
              documentType: type,
            );

        if (url != null) {
          ref.invalidate(currentDriverProfileProvider);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Document upload for $type successful!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload document'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Build the location settings section
  Widget _buildLocationSettingsSection(DriverProfileModel profile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Location Settings',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // My Current Location Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Current Location',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Location Address',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                // Location text field with map icon
                GestureDetector(
                  onTap: () => _openMapPicker(profile, 'current'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currentLocationText ??
                                profile.locationText ??
                                'No location set',
                            style: TextStyle(
                              color:
                                  (_currentLocationText ??
                                          profile.locationText) !=
                                      null
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.map_outlined,
                          color: Colors.blue.shade400,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Use My Current Location button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _useCurrentGPSLocation(profile, 'current'),
                    icon: const Icon(Icons.near_me, size: 18),
                    label: const Text('Use My Current Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Start Point Location Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Start Point Location',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    // Same as Current button
                    OutlinedButton.icon(
                      onPressed: _hasCurrentLocation(profile)
                          ? () => _copyToStartLocation(profile)
                          : null,
                      icon: const Icon(Icons.copy, size: 14),
                      label: const Text('Same as Current'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade600,
                        side: BorderSide(color: Colors.blue.shade300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Start Point Address',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                // Start location text field with map icon
                GestureDetector(
                  onTap: () => _openMapPicker(profile, 'start'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.startLocationText ?? 'No start point set',
                            style: TextStyle(
                              color: profile.startLocationText != null
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          Icons.map_outlined,
                          color: Colors.blue.shade400,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openMapPicker(
    DriverProfileModel profile,
    String locationType,
  ) async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null && mounted) {
      // result is LatLng from MapPickerScreen
      final lat = result.latitude;
      final lng = result.longitude;

      // Reverse geocode to get meaningful address
      final locationText = await _reverseGeocode(lat, lng);

      if (locationType == 'current' && mounted) {
        setState(() {
          _currentLocationText = locationText;
          _currentLocationLat = lat;
          _currentLocationLng = lng;
        });
      }

      final repository = ref.read(driverProfileRepositoryProvider);
      bool success;

      if (locationType == 'current') {
        success = await repository.updateDriverLocation(
          driverId: profile.id,
          locationText: locationText,
          lat: lat,
          lng: lng,
        );
      } else {
        success = await repository.updateStartLocation(
          driverId: profile.id,
          locationText: locationText,
          lat: lat,
          lng: lng,
        );
      }

      if (success && mounted) {
        ref.invalidate(currentDriverProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              locationType == 'current'
                  ? 'Current location updated!'
                  : 'Start point updated!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Reverse geocode coordinates to a meaningful address using Nominatim (free OSM API)
  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.example.gotosco_v3'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressObj = data['address'];

        if (addressObj != null) {
          // Build a readable address like: "Al Khwair, Way 4908, Muscat"
          List<String?> parts = [
            addressObj['building'],
            addressObj['road'],
            addressObj['suburb'] ?? addressObj['neighbourhood'],
            addressObj['city'] ?? addressObj['town'],
          ];

          final displayName = parts
              .where((e) => e != null && e.isNotEmpty)
              .toSet()
              .join(', ');

          if (displayName.isNotEmpty) {
            return displayName;
          }
        }

        // Fallback to first 3 parts of display_name
        final fallback = data['display_name']?.split(',').take(3).join(',');
        if (fallback != null && fallback.isNotEmpty) {
          return fallback.trim();
        }
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
    }

    // Ultimate fallback to coordinates
    return 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
  }

  Future<void> _useCurrentGPSLocation(
    DriverProfileModel profile,
    String locationType,
  ) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Getting your location...'),
          duration: Duration(seconds: 1),
        ),
      );

      final position = await Geolocator.getCurrentPosition();

      // Get meaningful address via reverse geocoding
      final locationText = await _reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (locationType == 'current' && mounted) {
        setState(() {
          _currentLocationText = locationText;
          _currentLocationLat = position.latitude;
          _currentLocationLng = position.longitude;
        });
      }

      final repository = ref.read(driverProfileRepositoryProvider);
      final success = await repository.updateDriverLocation(
        driverId: profile.id,
        locationText: locationText,
        lat: position.latitude,
        lng: position.longitude,
      );

      if (success && mounted) {
        ref.invalidate(currentDriverProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Current location updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _copyToStartLocation(DriverProfileModel profile) async {
    final repository = ref.read(driverProfileRepositoryProvider);
    final currentText = _currentLocationText ?? profile.locationText;
    final currentLat = _currentLocationLat ?? profile.locationLat;
    final currentLng = _currentLocationLng ?? profile.locationLng;
    bool success;

    if (currentText != null &&
        currentText.trim().isNotEmpty &&
        currentLat != null &&
        currentLng != null) {
      success = await repository.updateStartLocation(
        driverId: profile.id,
        locationText: currentText,
        lat: currentLat,
        lng: currentLng,
      );
    } else {
      success = await repository.copyLocationToStartPoint(profile.id);
    }

    if (success && mounted) {
      ref.invalidate(currentDriverProfileProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start point set to current location!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set current location first'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  bool _hasCurrentLocation(DriverProfileModel profile) {
    final text = _currentLocationText ?? profile.locationText;
    final lat = _currentLocationLat ?? profile.locationLat;
    final lng = _currentLocationLng ?? profile.locationLng;
    return text != null && text.trim().isNotEmpty && lat != null && lng != null;
  }

  /// Build the weekly schedule section
  Widget _buildScheduleSection() {
    final schedulesAsync = ref.watch(driverSchedulesProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.calendar_month, color: Colors.teal.shade600, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Weekly Schedule',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _showAddScheduleSheet,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Schedule list
          schedulesAsync.when(
            data: (schedules) {
              if (schedules.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No schedules set. Add your weekly availability to receive bookings.',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Group schedules by shift type and display as expandable sections
              final grouped = <String, List<DriverScheduleModel>>{};
              for (final schedule in schedules) {
                grouped.putIfAbsent(schedule.shiftType, () => []).add(schedule);
              }

              return Column(
                children: grouped.entries.map((entry) {
                  final shiftType = entry.key;
                  final shiftSchedules = entry.value;

                  // Determine icon and color based on shift type
                  IconData icon;
                  Color color;
                  String title;

                  if (shiftType == 'Go to School(s)') {
                    icon = Icons.school;
                    color = Colors.blue;
                    title = '🏫 Go to School(s)';
                  } else if (shiftType == 'Return from School(s)') {
                    icon = Icons.home;
                    color = Colors.green;
                    title = '🏠 Return from School(s)';
                  } else {
                    icon = Icons.settings;
                    color = Colors.purple;
                    title = '⚙️ Custom Schedule';
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Theme(
                      data: Theme.of(
                        context,
                      ).copyWith(dividerColor: Colors.transparent),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ExpansionPanelList(
                          elevation: 0,
                          expandedHeaderPadding: EdgeInsets.zero,
                          expansionCallback: (index, isExpanded) {
                            setState(() {
                              _expandedShiftType =
                                  (_expandedShiftType == shiftType)
                                  ? null
                                  : shiftType;
                            });
                          },
                          children: [
                            ExpansionPanel(
                              isExpanded: _expandedShiftType == shiftType,
                              backgroundColor: Colors.transparent,
                              canTapOnHeader: true,
                              headerBuilder: (context, isExpanded) {
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(icon, color: color, size: 20),
                                  ),
                                  title: Text(
                                    title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${shiftSchedules.length} day${shiftSchedules.length > 1 ? 's' : ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                );
                              },
                              body: Column(
                                children:
                                    (shiftSchedules..sort(
                                          (a, b) =>
                                              a.dayIndex.compareTo(b.dayIndex),
                                        ))
                                        .map((schedule) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                              left: 16,
                                              right: 8,
                                              bottom: 8,
                                            ),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.teal.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    schedule.dayDisplayName
                                                        .substring(0, 3)
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors.teal.shade700,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  schedule.timeRange,
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                const Spacer(),
                                                InkWell(
                                                  onTap: () =>
                                                      _showEditScheduleSheet(
                                                        schedule,
                                                      ),
                                                  child: Icon(
                                                    Icons.edit_outlined,
                                                    color: Colors.teal.shade600,
                                                    size: 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                InkWell(
                                                  onTap: () => _deleteSchedule(
                                                    schedule.id,
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: Colors.red.shade400,
                                                    size: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        })
                                        .toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text('Error loading schedules: $e'),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AddScheduleSheet(),
    );
  }

  void _showEditScheduleSheet(DriverScheduleModel schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EditScheduleSheet(schedule: schedule),
    );
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(driverProfileRepositoryProvider)
          .deleteSchedule(scheduleId);

      if (success) {
        ref.invalidate(driverSchedulesProvider);
        ref.invalidate(driverDashboardStateProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Schedule deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  void _showEditProfileSheet(DriverProfileModel profile) {
    context.push('/driver-profile-edit', extra: profile);
  }

  void _showCreateProfileSheet() {
    context.push('/driver-profile-create');
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Edit Profile Bottom Sheet
class DriverEditProfileSheet extends ConsumerStatefulWidget {
  final DriverProfileModel profile;
  final bool fullScreen;

  const DriverEditProfileSheet({
    super.key,
    required this.profile,
    this.fullScreen = false,
  });

  @override
  ConsumerState<DriverEditProfileSheet> createState() =>
      _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<DriverEditProfileSheet> {
  late TextEditingController _experienceController;
  late TextEditingController _licenseNumberController;
  late TextEditingController _vehicleNumberController;
  late TextEditingController _vehicleCapacityController;
  late TextEditingController _priceTwoWayController;
  late TextEditingController _priceOneWayController;
  late TextEditingController _priceDailyController;
  late TextEditingController _locationTextController;
  late TextEditingController _bioController;

  String _selectedVehicleType = 'Bus';
  DateTime? _licenseExpiry;
  double? _locationLat;
  double? _locationLng;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _experienceController = TextEditingController(
      text: widget.profile.experienceYears.toString(),
    );
    _licenseNumberController = TextEditingController(
      text: widget.profile.licenseNumber ?? '',
    );
    _vehicleNumberController = TextEditingController(
      text: widget.profile.vehicleNumber ?? '',
    );
    _vehicleCapacityController = TextEditingController(
      text: widget.profile.vehicleCapacity.toString(),
    );
    _priceTwoWayController = TextEditingController(
      text: widget.profile.priceMonthlyTwoWay.toString(),
    );
    _priceOneWayController = TextEditingController(
      text: widget.profile.priceMonthlyOneWay.toString(),
    );
    _priceDailyController = TextEditingController(
      text: widget.profile.priceDaily.toString(),
    );
    _locationTextController = TextEditingController(
      text: widget.profile.locationText ?? '',
    );
    _bioController = TextEditingController(text: widget.profile.bio);
    _selectedVehicleType = widget.profile.vehicleType;
    _licenseExpiry = widget.profile.licenseExpiry;
    _locationLat = widget.profile.locationLat;
    _locationLng = widget.profile.locationLng;
  }

  @override
  void dispose() {
    _experienceController.dispose();
    _licenseNumberController.dispose();
    _vehicleNumberController.dispose();
    _vehicleCapacityController.dispose();
    _priceTwoWayController.dispose();
    _priceOneWayController.dispose();
    _priceDailyController.dispose();
    _locationTextController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.fullScreen
          ? null
          : MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.fullScreen
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.green.shade500, width: 3)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Cancel'),
                ),
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Form fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('Driver Information'),
                  _buildTextField(
                    controller: _experienceController,
                    label: 'Years of Experience',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _licenseNumberController,
                    label: 'License Number',
                  ),
                  _buildDateField(),

                  const SizedBox(height: 24),
                  _buildSectionLabel('Vehicle Details'),
                  _buildVehicleTypeDropdown(),
                  _buildTextField(
                    controller: _vehicleNumberController,
                    label: 'Vehicle Number',
                  ),
                  _buildTextField(
                    controller: _vehicleCapacityController,
                    label: 'Capacity (children)',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionLabel('Pricing'),
                  _buildTextField(
                    controller: _priceTwoWayController,
                    label: 'Monthly Two-way (\$)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _priceOneWayController,
                    label: 'Monthly One-way (\$)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _priceDailyController,
                    label: 'Daily Rate (\$)',
                    keyboardType: TextInputType.number,
                  ),

                  const SizedBox(height: 24),
                  _buildSectionLabel('Location'),
                  _buildLocationPicker(),

                  const SizedBox(height: 24),
                  _buildSectionLabel('Bio'),
                  _buildTextField(
                    controller: _bioController,
                    label: 'Tell parents about yourself',
                    maxLines: 4,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final hasValue = controller.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: hasValue ? Colors.green.shade50 : Colors.red.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate:
                _licenseExpiry ?? DateTime.now().add(const Duration(days: 365)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 3650)),
          );
          if (date != null) {
            setState(() => _licenseExpiry = date);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'License Expiry Date',
            filled: true,
            fillColor: _licenseExpiry != null
                ? Colors.green.shade50
                : Colors.red.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            _licenseExpiry != null
                ? DateFormat('dd/MM/yyyy').format(_licenseExpiry!)
                : 'Select date',
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedVehicleType,
        decoration: InputDecoration(
          labelText: 'Vehicle Type',
          filled: true,
          fillColor: _selectedVehicleType.isNotEmpty
              ? Colors.green.shade50
              : Colors.red.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: ['Bus', 'Van', 'SUV', 'Sedan']
            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
            .toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedVehicleType = value);
          }
        },
      ),
    );
  }

  Widget _buildLocationPicker() {
    final hasLocation = _locationTextController.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _locationTextController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Location',
            filled: true,
            fillColor: hasLocation ? Colors.green.shade50 : Colors.red.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: const Icon(Icons.map_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Use Current Location'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openMapPicker,
                icon: const Icon(Icons.place_outlined, size: 18),
                label: const Text('Pick on Map'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null && mounted) {
      await _setLocationFromCoords(result.latitude, result.longitude);
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      await _setLocationFromCoords(position.latitude, position.longitude);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _setLocationFromCoords(double lat, double lng) async {
    final text = await _reverseGeocode(lat, lng);
    if (!mounted) return;
    setState(() {
      _locationLat = lat;
      _locationLng = lng;
      _locationTextController.text = text;
    });
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.example.gotosco_v3'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressObj = data['address'];
        if (addressObj != null) {
          List<String?> parts = [
            addressObj['building'],
            addressObj['road'],
            addressObj['suburb'] ?? addressObj['neighbourhood'],
            addressObj['city'] ?? addressObj['town'],
          ];
          final displayName = parts
              .where((e) => e != null && e.isNotEmpty)
              .toSet()
              .join(', ');
          if (displayName.isNotEmpty) return displayName;
        }
        final fallback = data['display_name']?.split(',').take(3).join(',');
        if (fallback != null && fallback.isNotEmpty) {
          return fallback.trim();
        }
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
    }
    return 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
  }

  bool _validateRequiredFields() {
    if (_vehicleNumberController.text.trim().isEmpty) {
      _showValidationError('Vehicle number is required.');
      return false;
    }
    if (_licenseNumberController.text.trim().isEmpty) {
      _showValidationError('License number is required.');
      return false;
    }
    final capacity = int.tryParse(_vehicleCapacityController.text) ?? 0;
    if (capacity <= 0) {
      _showValidationError('Vehicle capacity must be greater than 0.');
      return false;
    }
    if (_locationTextController.text.trim().isEmpty ||
        _locationLat == null ||
        _locationLng == null) {
      _showValidationError('Location is required.');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _saveProfile() async {
    if (!_validateRequiredFields()) {
      return;
    }

    setState(() => _isLoading = true);

    final updates = {
      'experience_years': int.tryParse(_experienceController.text) ?? 0,
      'license_number': _licenseNumberController.text,
      'license_expiry': _licenseExpiry?.toIso8601String().split('T').first,
      'vehicle_type': _selectedVehicleType,
      'vehicle_number': _vehicleNumberController.text,
      'vehicle_capacity': int.tryParse(_vehicleCapacityController.text) ?? 0,
      'price_monthly_two_way':
          double.tryParse(_priceTwoWayController.text) ?? 0,
      'price_monthly_one_way':
          double.tryParse(_priceOneWayController.text) ?? 0,
      'price_daily': double.tryParse(_priceDailyController.text) ?? 0,
      'location_text': _locationTextController.text,
      'bio': _bioController.text,
    };

    if (_locationLat != null && _locationLng != null) {
      updates['location_geo'] =
          'SRID=4326;POINT(${_locationLng} ${_locationLat})';
    }

    final success = await ref
        .read(driverProfileRepositoryProvider)
        .updateDriverProfile(widget.profile.id, updates);

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        // Invalidate all related providers to ensure data sync
        ref.invalidate(currentDriverProfileProvider);
        ref.invalidate(driverDashboardStateProvider);
        ref.invalidate(driverProfileProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class DriverEditProfileScreen extends StatelessWidget {
  final DriverProfileModel profile;

  const DriverEditProfileScreen({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: DriverEditProfileSheet(profile: profile, fullScreen: true),
    );
  }
}

class DriverCreateProfileScreen extends StatelessWidget {
  const DriverCreateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: const DriverCreateProfileSheet(fullScreen: true),
    );
  }
}

// Create Profile Bottom Sheet for new drivers
class DriverCreateProfileSheet extends ConsumerStatefulWidget {
  final bool fullScreen;

  const DriverCreateProfileSheet({super.key, this.fullScreen = false});

  @override
  ConsumerState<DriverCreateProfileSheet> createState() =>
      _CreateProfileSheetState();
}

class _CreateProfileSheetState extends ConsumerState<DriverCreateProfileSheet> {
  final _experienceController = TextEditingController(text: '0');
  final _licenseNumberController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleCapacityController = TextEditingController(text: '8');
  final _priceTwoWayController = TextEditingController();
  final _priceOneWayController = TextEditingController();
  final _priceDailyController = TextEditingController();
  final _locationTextController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedVehicleType = 'Van';
  DateTime? _licenseExpiry;
  double? _locationLat;
  double? _locationLng;
  bool _isLoading = false;

  @override
  void dispose() {
    _experienceController.dispose();
    _licenseNumberController.dispose();
    _vehicleNumberController.dispose();
    _vehicleCapacityController.dispose();
    _priceTwoWayController.dispose();
    _priceOneWayController.dispose();
    _priceDailyController.dispose();
    _locationTextController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.fullScreen
          ? null
          : MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.fullScreen
            ? BorderRadius.zero
            : const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.green.shade500, width: 3)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Cancel'),
                ),
                const Text(
                  'Create Driver Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _createProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Create',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Form fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('Vehicle Details (Required)'),
                  _buildVehicleTypeDropdown(),
                  _buildTextField(
                    controller: _vehicleNumberController,
                    label: 'Vehicle Number',
                  ),
                  _buildTextField(
                    controller: _vehicleCapacityController,
                    label: 'Capacity (number of children)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Driver Information'),
                  _buildTextField(
                    controller: _experienceController,
                    label: 'Years of Experience',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _licenseNumberController,
                    label: 'License Number',
                  ),
                  _buildDateField(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Pricing'),
                  _buildTextField(
                    controller: _priceTwoWayController,
                    label: 'Monthly Two-way (OMR)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _priceOneWayController,
                    label: 'Monthly One-way (OMR)',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _priceDailyController,
                    label: 'Daily Rate (OMR)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  _buildSectionLabel('Location'),
                  _buildLocationPicker(),
                  const SizedBox(height: 24),
                  _buildSectionLabel('About You'),
                  _buildTextField(
                    controller: _bioController,
                    label: 'Tell parents about yourself (optional)',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade800,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final hasValue = controller.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: hasValue ? Colors.green.shade50 : Colors.red.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDateField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now().add(const Duration(days: 365)),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 3650)),
          );
          if (date != null) {
            setState(() => _licenseExpiry = date);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'License Expiry Date',
            filled: true,
            fillColor: _licenseExpiry != null
                ? Colors.green.shade50
                : Colors.red.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          child: Text(
            _licenseExpiry != null
                ? DateFormat('dd/MM/yyyy').format(_licenseExpiry!)
                : 'Select date',
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: _selectedVehicleType,
        decoration: InputDecoration(
          labelText: 'Vehicle Type',
          filled: true,
          fillColor: _selectedVehicleType.isNotEmpty
              ? Colors.green.shade50
              : Colors.red.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: ['Bus', 'Van', 'SUV', 'Sedan']
            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
            .toList(),
        onChanged: (value) {
          if (value != null) setState(() => _selectedVehicleType = value);
        },
      ),
    );
  }

  Widget _buildLocationPicker() {
    final hasLocation = _locationTextController.text.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _locationTextController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Location',
            filled: true,
            fillColor: hasLocation ? Colors.green.shade50 : Colors.red.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: const Icon(Icons.map_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _useCurrentLocation,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Use Current Location'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _openMapPicker,
                icon: const Icon(Icons.place_outlined, size: 18),
                label: const Text('Pick on Map'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (context) => const MapPickerScreen()),
    );

    if (result != null && mounted) {
      await _setLocationFromCoords(result.latitude, result.longitude);
    }
  }

  Future<void> _useCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      await _setLocationFromCoords(position.latitude, position.longitude);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to get location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _setLocationFromCoords(double lat, double lng) async {
    final text = await _reverseGeocode(lat, lng);
    if (!mounted) return;
    setState(() {
      _locationLat = lat;
      _locationLng = lng;
      _locationTextController.text = text;
    });
  }

  Future<String> _reverseGeocode(double lat, double lng) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'com.example.gotosco_v3'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final addressObj = data['address'];
        if (addressObj != null) {
          List<String?> parts = [
            addressObj['building'],
            addressObj['road'],
            addressObj['suburb'] ?? addressObj['neighbourhood'],
            addressObj['city'] ?? addressObj['town'],
          ];
          final displayName = parts
              .where((e) => e != null && e.isNotEmpty)
              .toSet()
              .join(', ');
          if (displayName.isNotEmpty) return displayName;
        }
        final fallback = data['display_name']?.split(',').take(3).join(',');
        if (fallback != null && fallback.isNotEmpty) {
          return fallback.trim();
        }
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
    }
    return 'Location (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})';
  }

  Future<void> _createProfile() async {
    setState(() => _isLoading = true);

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_vehicleNumberController.text.trim().isEmpty) {
      _showValidationError('Vehicle number is required.');
      setState(() => _isLoading = false);
      return;
    }
    if (_licenseNumberController.text.trim().isEmpty) {
      _showValidationError('License number is required.');
      setState(() => _isLoading = false);
      return;
    }
    if (_licenseExpiry == null) {
      _showValidationError('License expiry date is required.');
      setState(() => _isLoading = false);
      return;
    }
    final capacity = int.tryParse(_vehicleCapacityController.text) ?? 0;
    if (capacity <= 0) {
      _showValidationError('Vehicle capacity must be greater than 0.');
      setState(() => _isLoading = false);
      return;
    }
    if (_locationTextController.text.trim().isEmpty ||
        _locationLat == null ||
        _locationLng == null) {
      _showValidationError('Location is required.');
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Create driver profile
      final payload = <String, dynamic>{
        'user_id': userId,
        'vehicle_type': _selectedVehicleType,
        'vehicle_number': _vehicleNumberController.text,
        'vehicle_capacity': int.tryParse(_vehicleCapacityController.text) ?? 8,
        'experience_years': int.tryParse(_experienceController.text) ?? 0,
        'license_number': _licenseNumberController.text,
        'license_expiry': _licenseExpiry?.toIso8601String().split('T').first,
        'price_monthly_two_way':
            double.tryParse(_priceTwoWayController.text) ?? 0,
        'price_monthly_one_way':
            double.tryParse(_priceOneWayController.text) ?? 0,
        'price_daily': double.tryParse(_priceDailyController.text) ?? 0,
        'location_text': _locationTextController.text,
        'bio': _bioController.text,
        'is_verified': false,
      };

      if (_locationLat != null && _locationLng != null) {
        payload['location_geo'] =
            'SRID=4326;POINT(${_locationLng} ${_locationLat})';
      }

      await Supabase.instance.client.from('drivers').insert(payload);

      setState(() => _isLoading = false);

      if (mounted) {
        // Invalidate all related providers to ensure data sync
        ref.invalidate(currentDriverProfileProvider);
        ref.invalidate(driverDashboardStateProvider);
        ref.invalidate(driverProfileProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ADD SCHEDULE SHEET
// ═══════════════════════════════════════════════════════════════════════════
class _AddScheduleSheet extends ConsumerStatefulWidget {
  const _AddScheduleSheet();

  @override
  ConsumerState<_AddScheduleSheet> createState() => _AddScheduleSheetState();
}

class _AddScheduleSheetState extends ConsumerState<_AddScheduleSheet> {
  String _selectedDay = 'sunday';
  String _selectedShiftType = 'Go to School(s)';
  TimeOfDay _fromTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _untilTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Schedule',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Quick Fill Section
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.teal.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.flash_on,
                        color: Colors.teal.shade700,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Quick Fill (Sun-Thu)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _quickFillSchedules(
                                  'Go to School(s)',
                                  '06:00:00',
                                  '08:00:00',
                                ),
                          icon: const Text(
                            '🏫',
                            style: TextStyle(fontSize: 16),
                          ),
                          label: const Text(
                            'To School\n6-8 AM',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
                            side: BorderSide(color: Colors.blue.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isLoading
                              ? null
                              : () => _quickFillSchedules(
                                  'Return from School(s)',
                                  '13:00:00',
                                  '15:00:00',
                                ),
                          icon: const Text(
                            '🏠',
                            style: TextStyle(fontSize: 16),
                          ),
                          label: const Text(
                            'From School\n1-3 PM',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green.shade700,
                            side: BorderSide(color: Colors.green.shade300),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 12),

            // Manual Entry Section
            Text(
              'Or Add Single Day',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),

            // Day Selection
            const Text(
              'Day of Week',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: DriverScheduleModel.validDays
                  .map(
                    (day) => DropdownMenuItem(
                      value: day,
                      child: Text(day[0].toUpperCase() + day.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedDay = value!),
            ),

            const SizedBox(height: 16),

            // Shift Type Selection
            const Text(
              'Shift Type',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedShiftType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: DriverScheduleModel.validShiftTypes
                  .map(
                    (shift) => DropdownMenuItem(
                      value: shift,
                      child: Text(
                        DriverScheduleModel.shiftTypeDisplayNames[shift] ??
                            shift,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedShiftType = value!),
            ),

            const SizedBox(height: 16),

            // Time Selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectTime(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 8),
                              Text(_fromTime.format(context)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Until',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectTime(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 8),
                              Text(_untilTime.format(context)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Add Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Add Schedule',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? _fromTime : _untilTime,
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromTime = picked;
        } else {
          _untilTime = picked;
        }
      });
    }
  }

  String _formatTimeForDb(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  /// Quick fill schedules for Sun-Thu with preset times
  Future<void> _quickFillSchedules(
    String shiftType,
    String fromTime,
    String untilTime,
  ) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    // School week days: Sunday to Thursday
    const schoolDays = ['sunday', 'monday', 'tuesday', 'wednesday', 'thursday'];
    int successCount = 0;

    try {
      for (final day in schoolDays) {
        final schedule = DriverScheduleModel(
          id: '',
          driverId: userId,
          dayOfWeek: day,
          shiftType: shiftType,
          availableFrom: fromTime,
          availableUntil: untilTime,
        );

        final scheduleId = await ref
            .read(driverProfileRepositoryProvider)
            .createSchedule(schedule);
        if (scheduleId != null) successCount++;
      }

      if (mounted) {
        ref.invalidate(driverSchedulesProvider);
        ref.invalidate(driverDashboardStateProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Added $successCount schedules for ${shiftType.trim()}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addSchedule() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);

    try {
      final schedule = DriverScheduleModel(
        id: '',
        driverId: userId,
        dayOfWeek: _selectedDay,
        shiftType: _selectedShiftType,
        availableFrom: _formatTimeForDb(_fromTime),
        availableUntil: _formatTimeForDb(_untilTime),
      );

      final scheduleId = await ref
          .read(driverProfileRepositoryProvider)
          .createSchedule(schedule);

      if (scheduleId != null && mounted) {
        ref.invalidate(driverSchedulesProvider);
        ref.invalidate(driverDashboardStateProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EDIT SCHEDULE SHEET
// ═══════════════════════════════════════════════════════════════════════════
class _EditScheduleSheet extends ConsumerStatefulWidget {
  final DriverScheduleModel schedule;

  const _EditScheduleSheet({required this.schedule});

  @override
  ConsumerState<_EditScheduleSheet> createState() => _EditScheduleSheetState();
}

class _EditScheduleSheetState extends ConsumerState<_EditScheduleSheet> {
  late String _selectedDay;
  late String _selectedShiftType;
  late TimeOfDay _fromTime;
  late TimeOfDay _untilTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.schedule.dayOfWeek;
    _selectedShiftType = widget.schedule.shiftType;
    _fromTime = _parseTime(widget.schedule.availableFrom);
    _untilTime = _parseTime(widget.schedule.availableUntil);
  }

  TimeOfDay _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 6,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Edit Schedule',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Day Selection
            const Text(
              'Day of Week',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: DriverScheduleModel.validDays
                  .map(
                    (day) => DropdownMenuItem(
                      value: day,
                      child: Text(day[0].toUpperCase() + day.substring(1)),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedDay = value!),
            ),

            const SizedBox(height: 16),

            // Shift Type Selection
            const Text(
              'Shift Type',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedShiftType,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: DriverScheduleModel.validShiftTypes
                  .map(
                    (shift) => DropdownMenuItem(
                      value: shift,
                      child: Text(
                        DriverScheduleModel.shiftTypeDisplayNames[shift] ??
                            shift,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedShiftType = value!),
            ),

            const SizedBox(height: 16),

            // Time Selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectTime(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 8),
                              Text(_fromTime.format(context)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Until',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectTime(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 8),
                              Text(_untilTime.format(context)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isFrom) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? _fromTime : _untilTime,
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromTime = picked;
        } else {
          _untilTime = picked;
        }
      });
    }
  }

  String _formatTimeForDb(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  Future<void> _saveSchedule() async {
    setState(() => _isLoading = true);

    try {
      final updates = {
        'day_of_week': _selectedDay,
        'shift_type': _selectedShiftType,
        'available_from': _formatTimeForDb(_fromTime),
        'available_until': _formatTimeForDb(_untilTime),
      };

      final success = await ref
          .read(driverProfileRepositoryProvider)
          .updateSchedule(widget.schedule.id, updates);

      if (success && mounted) {
        ref.invalidate(driverSchedulesProvider);
        ref.invalidate(driverDashboardStateProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update schedule: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
