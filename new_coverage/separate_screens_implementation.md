# School Transport App - Separate Coverage Screens Implementation

## 📱 Screen Structure

```
Coverage Management (Main Entry)
├── Areas Coverage Screen (Separate)
└── Schools Coverage Screen (Separate)
```

## 🗂️ Flutter Project Structure

```
lib/
├── models/
│   ├── city.dart
│   ├── area.dart
│   └── school.dart
├── services/
│   ├── areas_coverage_service.dart
│   └── schools_coverage_service.dart
├── screens/
│   ├── coverage_menu_screen.dart        # Entry point with 2 options
│   ├── areas_coverage_screen.dart       # Areas management
│   └── schools_coverage_screen.dart     # Schools management
└── widgets/
    ├── city_card.dart
    └── search_bar_widget.dart
```

## 📊 Supabase Database Schema

```sql
-- Cities Table
CREATE TABLE cities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  country VARCHAR(100) DEFAULT 'Oman',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Areas Table
CREATE TABLE areas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  city_id UUID REFERENCES cities(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(city_id, name)
);

-- Schools Table
CREATE TABLE schools (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  city_id UUID REFERENCES cities(id) ON DELETE CASCADE,
  name VARCHAR(200) NOT NULL,
  location VARCHAR(100), -- area/neighborhood within city
  created_at TIMESTAMP DEFAULT NOW()
);

-- Drivers Table
CREATE TABLE drivers (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(100),
  created_at TIMESTAMP DEFAULT NOW()
);

-- Driver Area Coverage
CREATE TABLE driver_area_coverage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  area_id UUID REFERENCES areas(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(driver_id, area_id)
);

-- Driver School Coverage
CREATE TABLE driver_school_coverage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  school_id UUID REFERENCES schools(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(driver_id, school_id)
);

-- Driver City All Areas Coverage
CREATE TABLE driver_city_all_areas_coverage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  city_id UUID REFERENCES cities(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(driver_id, city_id)
);

-- Driver City All Schools Coverage
CREATE TABLE driver_city_all_schools_coverage (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
  city_id UUID REFERENCES cities(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(driver_id, city_id)
);

-- Indexes
CREATE INDEX idx_areas_city ON areas(city_id);
CREATE INDEX idx_areas_name ON areas(name);
CREATE INDEX idx_schools_city ON schools(city_id);
CREATE INDEX idx_schools_name ON schools(name);
CREATE INDEX idx_schools_location ON schools(location);
CREATE INDEX idx_driver_area_coverage_driver ON driver_area_coverage(driver_id);
CREATE INDEX idx_driver_school_coverage_driver ON driver_school_coverage(driver_id);
```

## 📱 Flutter Implementation

### 1. Coverage Menu Screen (Entry Point)

```dart
// coverage_menu_screen.dart
import 'package:flutter/material.dart';
import 'areas_coverage_screen.dart';
import 'schools_coverage_screen.dart';

class CoverageMenuScreen extends StatelessWidget {
  final String driverId;

  const CoverageMenuScreen({required this.driverId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Manage Coverage',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Description Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFBF1),
                border: Border.all(color: const Color(0xFF99F6E4)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF14B8A6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.info_outline, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Configure where you can provide transportation services',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Areas Coverage Card
            _buildCoverageOptionCard(
              context: context,
              title: 'Areas Coverage',
              subtitle: 'Select neighborhoods and locations you serve',
              icon: Icons.location_on,
              iconColor: const Color(0xFF3B82F6),
              iconBgColor: const Color(0xFFDBEAFE),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AreasCoverageScreen(driverId: driverId),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Schools Coverage Card
            _buildCoverageOptionCard(
              context: context,
              title: 'Schools Coverage',
              subtitle: 'Select schools you can serve',
              icon: Icons.school,
              iconColor: const Color(0xFF8B5CF6),
              iconBgColor: const Color(0xFFEDE9FE),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SchoolsCoverageScreen(driverId: driverId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverageOptionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 24),
          ],
        ),
      ),
    );
  }
}
```

### 2. Areas Coverage Screen

```dart
// areas_coverage_screen.dart
import 'package:flutter/material.dart';
import '../models/city.dart';
import '../models/area.dart';
import '../services/areas_coverage_service.dart';

class AreasCoverageScreen extends StatefulWidget {
  final String driverId;

  const AreasCoverageScreen({required this.driverId, Key? key}) : super(key: key);

  @override
  State<AreasCoverageScreen> createState() => _AreasCoverageScreenState();
}

class _AreasCoverageScreenState extends State<AreasCoverageScreen> {
  final AreasCoverageService _service = AreasCoverageService();
  final TextEditingController _searchController = TextEditingController();
  
  List<CityWithAreas> _cities = [];
  List<CityWithAreas> _filteredCities = [];
  bool _isLoading = true;
  String? _expandedCityId;

  @override
  void initState() {
    super.initState();
    _loadCoverage();
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCoverage() async {
    try {
      final cities = await _service.fetchCitiesWithAreas(widget.driverId);
      setState(() {
        _cities = cities;
        _filteredCities = cities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading areas: $e');
    }
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() => _filteredCities = _cities);
      return;
    }

    setState(() {
      _filteredCities = _cities
          .map((city) => CityWithAreas(
                id: city.id,
                name: city.name,
                allAreasSelected: city.allAreasSelected,
                areas: city.areas
                    .where((area) =>
                        area.name.toLowerCase().contains(query) ||
                        city.name.toLowerCase().contains(query))
                    .toList(),
              ))
          .where((city) => city.areas.isNotEmpty)
          .toList();
    });
  }

  int _getTotalSelectedAreas() {
    return _cities.fold(0, (sum, city) => sum + city.areas.where((a) => a.selected).length);
  }

  void _toggleAllAreas(String cityId) {
    setState(() {
      final cityIndex = _cities.indexWhere((c) => c.id == cityId);
      if (cityIndex != -1) {
        final city = _cities[cityIndex];
        final newAllAreasSelected = !city.allAreasSelected;
        
        _cities[cityIndex] = CityWithAreas(
          id: city.id,
          name: city.name,
          allAreasSelected: newAllAreasSelected,
          areas: city.areas.map((a) => a.copyWith(selected: newAllAreasSelected)).toList(),
        );
        _filterCities();
      }
    });
  }

  void _toggleArea(String cityId, String areaId) {
    setState(() {
      final cityIndex = _cities.indexWhere((c) => c.id == cityId);
      if (cityIndex != -1) {
        final city = _cities[cityIndex];
        final newAreas = city.areas.map((area) {
          if (area.id == areaId) {
            return area.copyWith(selected: !area.selected);
          }
          return area;
        }).toList();

        _cities[cityIndex] = CityWithAreas(
          id: city.id,
          name: city.name,
          allAreasSelected: newAreas.every((a) => a.selected),
          areas: newAreas,
        );
        _filterCities();
      }
    });
  }

  Future<void> _saveCoverage() async {
    try {
      await _service.saveCoverage(widget.driverId, _cities);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Areas coverage saved successfully')),
      );
    } catch (e) {
      _showError('Error saving coverage: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Areas Coverage',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_getTotalSelectedAreas()} area${_getTotalSelectedAreas() != 1 ? 's' : ''} selected',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search cities or areas...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _filteredCities.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildSummaryCard(),
                            const SizedBox(height: 16),
                            ..._filteredCities.map((city) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildCityCard(city),
                                )),
                          ],
                        ),
                ),
                _buildSaveButton(),
              ],
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFCCFBF1),
        border: Border.all(color: const Color(0xFF99F6E4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF14B8A6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Service Areas',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose the neighborhoods and areas where you can provide transportation services.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(CityWithAreas city) {
    final isExpanded = _expandedCityId == city.id;
    final selectedCount = city.areas.where((a) => a.selected).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCityId = isExpanded ? null : city.id;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${city.areas.length} area${city.areas.length != 1 ? 's' : ''} available',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedCount > 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF14B8A6),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$selectedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSelectAllCheckbox(city),
                  const SizedBox(height: 8),
                  ...city.areas.map((area) => _buildAreaCheckbox(city.id, area)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectAllCheckbox(CityWithAreas city) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFCCFBF1),
        border: Border.all(color: const Color(0xFF14B8A6), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: city.allAreasSelected,
              onChanged: (value) => _toggleAllAreas(city.id),
              activeColor: const Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Areas in ${city.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Select all ${city.areas.length} areas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCheckbox(String cityId, Area area) {
    return InkWell(
      onTap: () => _toggleArea(cityId, area.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: area.selected,
                onChanged: (value) => _toggleArea(cityId, area.id),
                activeColor: const Color(0xFF14B8A6),
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.location_on, size: 18, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                area.name,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No areas found matching "${_searchController.text}"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveCoverage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Save Areas Coverage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 3. Schools Coverage Screen

```dart
// schools_coverage_screen.dart
import 'package:flutter/material.dart';
import '../models/city.dart';
import '../models/school.dart';
import '../services/schools_coverage_service.dart';

class SchoolsCoverageScreen extends StatefulWidget {
  final String driverId;

  const SchoolsCoverageScreen({required this.driverId, Key? key}) : super(key: key);

  @override
  State<SchoolsCoverageScreen> createState() => _SchoolsCoverageScreenState();
}

class _SchoolsCoverageScreenState extends State<SchoolsCoverageScreen> {
  final SchoolsCoverageService _service = SchoolsCoverageService();
  final TextEditingController _searchController = TextEditingController();
  
  List<CityWithSchools> _cities = [];
  List<CityWithSchools> _filteredCities = [];
  bool _isLoading = true;
  String? _expandedCityId;

  @override
  void initState() {
    super.initState();
    _loadCoverage();
    _searchController.addListener(_filterCities);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCoverage() async {
    try {
      final cities = await _service.fetchCitiesWithSchools(widget.driverId);
      setState(() {
        _cities = cities;
        _filteredCities = cities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading schools: $e');
    }
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase().trim();
    
    if (query.isEmpty) {
      setState(() => _filteredCities = _cities);
      return;
    }

    setState(() {
      _filteredCities = _cities
          .map((city) => CityWithSchools(
                id: city.id,
                name: city.name,
                allSchoolsSelected: city.allSchoolsSelected,
                schools: city.schools
                    .where((school) =>
                        school.name.toLowerCase().contains(query) ||
                        (school.location?.toLowerCase().contains(query) ?? false) ||
                        city.name.toLowerCase().contains(query))
                    .toList(),
              ))
          .where((city) => city.schools.isNotEmpty)
          .toList();
    });
  }

  int _getTotalSelectedSchools() {
    return _cities.fold(0, (sum, city) => sum + city.schools.where((s) => s.selected).length);
  }

  void _toggleAllSchools(String cityId) {
    setState(() {
      final cityIndex = _cities.indexWhere((c) => c.id == cityId);
      if (cityIndex != -1) {
        final city = _cities[cityIndex];
        final newAllSchoolsSelected = !city.allSchoolsSelected;
        
        _cities[cityIndex] = CityWithSchools(
          id: city.id,
          name: city.name,
          allSchoolsSelected: newAllSchoolsSelected,
          schools: city.schools.map((s) => s.copyWith(selected: newAllSchoolsSelected)).toList(),
        );
        _filterCities();
      }
    });
  }

  void _toggleSchool(String cityId, String schoolId) {
    setState(() {
      final cityIndex = _cities.indexWhere((c) => c.id == cityId);
      if (cityIndex != -1) {
        final city = _cities[cityIndex];
        final newSchools = city.schools.map((school) {
          if (school.id == schoolId) {
            return school.copyWith(selected: !school.selected);
          }
          return school;
        }).toList();

        _cities[cityIndex] = CityWithSchools(
          id: city.id,
          name: city.name,
          allSchoolsSelected: newSchools.every((s) => s.selected),
          schools: newSchools,
        );
        _filterCities();
      }
    });
  }

  Future<void> _saveCoverage() async {
    try {
      await _service.saveCoverage(widget.driverId, _cities);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schools coverage saved successfully')),
      );
    } catch (e) {
      _showError('Error saving coverage: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Schools Coverage',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_getTotalSelectedSchools()} school${_getTotalSelectedSchools() != 1 ? 's' : ''} selected',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search schools, locations, or cities...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _filteredCities.isEmpty
                      ? _buildEmptyState()
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            _buildSummaryCard(),
                            const SizedBox(height: 16),
                            ..._filteredCities.map((city) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildCityCard(city),
                                )),
                          ],
                        ),
                ),
                _buildSaveButton(),
              ],
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFCCFBF1),
        border: Border.all(color: const Color(0xFF99F6E4)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFF14B8A6),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select School Coverage',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose the schools where you can pick up and drop off students.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityCard(CityWithSchools city) {
    final isExpanded = _expandedCityId == city.id;
    final selectedCount = city.schools.where((s) => s.selected).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedCityId = isExpanded ? null : city.id;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_right,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${city.schools.length} school${city.schools.length != 1 ? 's' : ''} available',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedCount > 0)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF14B8A6),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$selectedCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSelectAllCheckbox(city),
                  const SizedBox(height: 8),
                  ...city.schools.map((school) => _buildSchoolCheckbox(city.id, school)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectAllCheckbox(CityWithSchools city) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFCCFBF1),
        border: Border.all(color: const Color(0xFF14B8A6), width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: city.allSchoolsSelected,
              onChanged: (value) => _toggleAllSchools(city.id),
              activeColor: const Color(0xFF14B8A6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Schools in ${city.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'Select all ${city.schools.length} schools',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolCheckbox(String cityId, School school) {
    return InkWell(
      onTap: () => _toggleSchool(cityId, school.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: school.selected,
                onChanged: (value) => _toggleSchool(cityId, school.id),
                activeColor: const Color(0xFF14B8A6),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.school, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          school.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (school.location != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 26),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            school.location!,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No schools found matching "${_searchController.text}"',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saveCoverage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF14B8A6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Save Schools Coverage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### 4. Models

```dart
// city.dart
class CityWithAreas {
  final String id;
  final String name;
  final bool allAreasSelected;
  final List<Area> areas;

  CityWithAreas({
    required this.id,
    required this.name,
    required this.allAreasSelected,
    required this.areas,
  });
}

class CityWithSchools {
  final String id;
  final String name;
  final bool allSchoolsSelected;
  final List<School> schools;

  CityWithSchools({
    required this.id,
    required this.name,
    required this.allSchoolsSelected,
    required this.schools,
  });
}

// area.dart
class Area {
  final String id;
  final String cityId;
  final String name;
  final bool selected;

  Area({
    required this.id,
    required this.cityId,
    required this.name,
    this.selected = false,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      cityId: json['city_id'],
      name: json['name'],
    );
  }

  Area copyWith({bool? selected}) {
    return Area(
      id: id,
      cityId: cityId,
      name: name,
      selected: selected ?? this.selected,
    );
  }
}

// school.dart
class School {
  final String id;
  final String cityId;
  final String name;
  final String? location;
  final bool selected;

  School({
    required this.id,
    required this.cityId,
    required this.name,
    this.location,
    this.selected = false,
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'],
      cityId: json['city_id'],
      name: json['name'],
      location: json['location'],
    );
  }

  School copyWith({bool? selected}) {
    return School(
      id: id,
      cityId: cityId,
      name: name,
      location: location,
      selected: selected ?? this.selected,
    );
  }
}
```

### 5. Services

```dart
// areas_coverage_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class AreasCoverageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CityWithAreas>> fetchCitiesWithAreas(String driverId) async {
    // Fetch all cities
    final citiesResponse = await _supabase.from('cities').select().order('name');

    List<CityWithAreas> cities = [];

    for (var cityJson in citiesResponse) {
      // Fetch areas for this city
      final areasResponse = await _supabase
          .from('areas')
          .select()
          .eq('city_id', cityJson['id'])
          .order('name');

      // Fetch driver's area coverage
      final driverAreaCoverage = await _supabase
          .from('driver_area_coverage')
          .select('area_id')
          .eq('driver_id', driverId);

      // Check if driver covers all areas in city
      final allAreasCoverage = await _supabase
          .from('driver_city_all_areas_coverage')
          .select()
          .eq('driver_id', driverId)
          .eq('city_id', cityJson['id']);

      // Mark selected areas
      final selectedAreaIds = driverAreaCoverage.map((d) => d['area_id']).toSet();
      final areas = (areasResponse as List).map((areaJson) {
        final area = Area.fromJson(areaJson);
        return area.copyWith(selected: selectedAreaIds.contains(area.id));
      }).toList();

      cities.add(CityWithAreas(
        id: cityJson['id'],
        name: cityJson['name'],
        allAreasSelected: allAreasCoverage.isNotEmpty,
        areas: areas,
      ));
    }

    return cities;
  }

  Future<void> saveCoverage(String driverId, List<CityWithAreas> cities) async {
    // Delete existing area coverage
    await _supabase.from('driver_area_coverage').delete().eq('driver_id', driverId);
    await _supabase.from('driver_city_all_areas_coverage').delete().eq('driver_id', driverId);

    // Insert new coverage
    for (var city in cities) {
      if (city.allAreasSelected) {
        await _supabase.from('driver_city_all_areas_coverage').insert({
          'driver_id': driverId,
          'city_id': city.id,
        });
      } else {
        final selectedAreas = city.areas.where((a) => a.selected).toList();
        if (selectedAreas.isNotEmpty) {
          await _supabase.from('driver_area_coverage').insert(
            selectedAreas.map((area) => {
              'driver_id': driverId,
              'area_id': area.id,
            }).toList(),
          );
        }
      }
    }
  }
}

// schools_coverage_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class SchoolsCoverageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<CityWithSchools>> fetchCitiesWithSchools(String driverId) async {
    // Fetch all cities
    final citiesResponse = await _supabase.from('cities').select().order('name');

    List<CityWithSchools> cities = [];

    for (var cityJson in citiesResponse) {
      // Fetch schools for this city
      final schoolsResponse = await _supabase
          .from('schools')
          .select()
          .eq('city_id', cityJson['id'])
          .order('name');

      // Fetch driver's school coverage
      final driverSchoolCoverage = await _supabase
          .from('driver_school_coverage')
          .select('school_id')
          .eq('driver_id', driverId);

      // Check if driver covers all schools in city
      final allSchoolsCoverage = await _supabase
          .from('driver_city_all_schools_coverage')
          .select()
          .eq('driver_id', driverId)
          .eq('city_id', cityJson['id']);

      // Mark selected schools
      final selectedSchoolIds = driverSchoolCoverage.map((d) => d['school_id']).toSet();
      final schools = (schoolsResponse as List).map((schoolJson) {
        final school = School.fromJson(schoolJson);
        return school.copyWith(selected: selectedSchoolIds.contains(school.id));
      }).toList();

      cities.add(CityWithSchools(
        id: cityJson['id'],
        name: cityJson['name'],
        allSchoolsSelected: allSchoolsCoverage.isNotEmpty,
        schools: schools,
      ));
    }

    return cities;
  }

  Future<void> saveCoverage(String driverId, List<CityWithSchools> cities) async {
    // Delete existing school coverage
    await _supabase.from('driver_school_coverage').delete().eq('driver_id', driverId);
    await _supabase.from('driver_city_all_schools_coverage').delete().eq('driver_id', driverId);

    // Insert new coverage
    for (var city in cities) {
      if (city.allSchoolsSelected) {
        await _supabase.from('driver_city_all_schools_coverage').insert({
          'driver_id': driverId,
          'city_id': city.id,
        });
      } else {
        final selectedSchools = city.schools.where((s) => s.selected).toList();
        if (selectedSchools.isNotEmpty) {
          await _supabase.from('driver_school_coverage').insert(
            selectedSchools.map((school) => {
              'driver_id': driverId,
              'school_id': school.id,
            }).toList(),
          );
        }
      }
    }
  }
}
```

## 🚀 Usage

```dart
// Navigate to coverage menu
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => CoverageMenuScreen(driverId: currentDriverId),
  ),
);
```

## ✅ Key Features

1. **Separate Screens**: Clean separation of Areas and Schools management
2. **Real-time Search**: Filter by city, area name, school name, or location
3. **Smart Counters**: Live count of selected items in header
4. **Select All Options**: Quickly select all items in a city
5. **Empty States**: Clear messaging when no search results found
6. **Visual Hierarchy**: Expandable city cards with clear organization
7. **Efficient Storage**: Optimized database queries and separate tables
8. **Independent Management**: Areas and Schools can be managed separately

## 🎯 Benefits

- **Cleaner UI**: Focused experience for each type of coverage
- **Better Performance**: Load only what's needed for each screen
- **Easier Navigation**: Clear mental model with separate concerns
- **Faster Search**: Search within specific domain (areas OR schools)
- **Scalability**: Easy to add new coverage types in future
