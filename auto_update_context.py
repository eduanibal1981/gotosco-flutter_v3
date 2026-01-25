
import os
import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# ==========================================
# 1. إعدادات المستندات (تم إضافة قسم جديد)
# ==========================================
DOCS_MAP = {
    "DB":         "YOUR_DATABASE_DOC_ID_HERE",  
    "LOGIC":      "1fhFjNQoH2DT7ylyocJI_q9UvHkvMM_eWSU6ALsnMKT0", # الـ ID القديم الخاص بالمنطق (يعمل بنجاح)
    
    # --- تم تقسيم الواجهة إلى قسمين ---
    "UI_SCREENS": "1fBoTUXEq30TBGusdRTm-9hqQPbKHoWgrXsDiFO7It1M", # استخدم الـ ID القديم للشاشات
    "UI_WIDGETS": "1kbdYDbTV_pBlJC9iriLvenJJC-PqQrEyuRBmDxYLLWc"      # <--- أنشئ مستنداً جديداً وضع الـ ID هنا
}

# ==========================================
# 2. منطق تقسيم الملفات (Scanning Logic)
# ==========================================
def get_category(file_path):
    path = file_path.replace("\\", "/")
    
    # --- 1. Database ---
    if "supabase/" in path and path.endswith(".sql"):
        return "DB"
    
    # تجاهل الملفات غير المهمة
    if not path.endswith((".dart", ".sql")):
        return None
    if "generated" in path or ".g.dart" in path or ".freezed.dart" in path:
        return None 

    # --- 2. Logic (Business Logic & Data) ---
    if (
        "/data/" in path or 
        "/models/" in path or 
        "_repository.dart" in path or 
        "_controller.dart" in path or 
        "_service.dart" in path or
        "_provider.dart" in path or
        "lib/core/" in path and "widgets" not in path
    ):
        return "LOGIC"

    # --- 3. UI Split Strategy ---
    # هل الملف يعتبر واجهة مستخدم؟
    is_ui = (
        "/presentation/" in path or 
        "/widgets/" in path or 
        "_screen.dart" in path or 
        "_tab.dart" in path or
        "_view.dart" in path
    )

    if is_ui:
        # تقسيم فرعي: هل هو شاشة أم ويدجت؟
        if "_screen.dart" in path or "/screens/" in path:
            return "UI_SCREENS"
        else:
            return "UI_WIDGETS" # يشمل widgets, tabs, views, dialogs

    return None

def generate_project_context():
    print("🚀 Starting project scan (Split UI Mode)...")
    # تحديث القاموس ليشمل الأقسام الجديدة
    context_data = {"DB": "", "LOGIC": "", "UI_SCREENS": "", "UI_WIDGETS": ""}
    files_count = {"DB": 0, "LOGIC": 0, "UI_SCREENS": 0, "UI_WIDGETS": 0}

    for root, dirs, files in os.walk("."):
        if any(ignore in root for ignore in [".git", "build", ".dart_tool", "ios", "android", "web", "venv"]):
            continue
            
        for file in files:
            file_path = os.path.join(root, file)
            category = get_category(file_path)
            
            if category:
                try:
                    with open(file_path, "r", encoding="utf-8") as infile:
                        content = infile.read()
                        
                    formatted_content = (
                        f"\n{'='*60}\n"
                        f"FILE: {file_path}\n"
                        f"{'='*60}\n"
                        f"{content}\n"
                    )
                    context_data[category] += formatted_content
                    files_count[category] += 1
                except Exception as e:
                    print(f"Skipping {file_path}: {e}")

    print("✅ Scan complete!")
    for cat, count in files_count.items():
        print(f"   - {cat}: {count} files found.")
    
    return context_data

# ==========================================
# 3. منطق الاتصال بجوجل (Google Docs API)
# ==========================================
SCOPES = ['https://www.googleapis.com/auth/documents']

def authenticate():
    creds = None
    if os.path.exists('token.json'):
        creds = Credentials.from_authorized_user_file('token.json', SCOPES)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file(
                'credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token.json', 'w') as token:
            token.write(creds.to_json())
    return creds

def update_google_doc(service, doc_id, new_content):
    if not doc_id or "YOUR_" in doc_id:
        print(f"⚠️ Skipping update for undefined Doc ID.")
        return

    try:
        doc = service.documents().get(documentId=doc_id).execute()
        content = doc.get('body').get('content', [])
        
        if not content:
            content_len = 0
        else:
            content_len = content[-1].get('endIndex')

        requests = []
        
        if content_len > 2:
            requests.append({
                'deleteContentRange': {
                    'range': {
                        'startIndex': 1,
                        'endIndex': content_len - 1
                    }
                }
            })

        if len(new_content) > 1000000:
            print(f"⚠️ Content STILL too large ({len(new_content)} chars)! Truncating...")
            new_content = new_content[:1000000] + "\n...[TRUNCATED]"

        requests.append({
            'insertText': {
                'location': {'index': 1},
                'text': new_content if new_content else "(No content found for this category)"
            }
        })

        service.documents().batchUpdate(documentId=doc_id, body={'requests': requests}).execute()
        print(f"✅ Updated Doc ({doc_id}) successfully.")

    except Exception as e:
        print(f"❌ Failed to update doc {doc_id}. Error: {e}")

# ==========================================
# 4. التشغيل الرئيسي
# ==========================================
def main():
    context_data = generate_project_context()
    
    print("\n🔑 Authenticating with Google...")
    try:
        creds = authenticate()
        service = build('docs', 'v1', credentials=creds)
        
        print("\n📤 Uploading to Google Docs...")
        for category, content in context_data.items():
            doc_id = DOCS_MAP.get(category)
            # تخطي التحديث إذا لم يكن هناك ملفات في القسم
            if not content and not doc_id:
                continue
                
            print(f"   -> Processing {category} ({len(content)} chars)...")
            update_google_doc(service, doc_id, content)
            
        print("\n🎉 All Done! Don't forget to add the NEW Doc to NotebookLM and click 'Sync'.")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")

if __name__ == '__main__':
    main()