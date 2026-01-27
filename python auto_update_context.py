import os
import os.path
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

# ==========================================
# 1. إعدادات المستندات (يجب تعديلها)
# ==========================================
DOCS_MAP = {
    "DB":    "1NHImIKLMSqeyEDmpV1dZsyvhetg7NH5vh2kP0TBKMBE",  # ضع ID مستند قاعدة البيانات هنا
    "LOGIC": "1fhFjNQoH2DT7ylyocJI_q9UvHkvMM_eWSU6ALsnMKT0",     # ضع ID مستند المنطق هنا
    "UI":    "1fBoTUXEq30TBGusdRTm-9hqQPbKHoWgrXsDiFO7It1M"         # ضع ID مستند الواجهة هنا
}

# ==========================================
# 2. منطق تقسيم الملفات (Scanning Logic)
# ==========================================
def get_category(file_path):
    path = file_path.replace("\\", "/")
    
    # تصنيف قاعدة البيانات
    if "supabase/" in path and path.endswith(".sql"):
        return "DB"
    
    # تجاهل الملفات غير المهمة
    if not path.endswith((".dart", ".sql")):
        return None
    if "generated" in path or ".g.dart" in path or ".freezed.dart" in path:
        return None 

    # تصنيف المنطق (Logic)
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

    # تصنيف الواجهة (UI)
    if (
        "/presentation/" in path or 
        "/widgets/" in path or 
        "_screen.dart" in path or 
        "_tab.dart" in path or
        "_view.dart" in path
    ):
        return "UI"

    return None

def generate_project_context():
    """
    يقوم بمسح المشروع وتجميع الكود في نصوص جاهزة
    Returns: dictionary { 'DB': 'content...', 'LOGIC': '...', 'UI': '...' }
    """
    print("🚀 Starting project scan...")
    context_data = {"DB": "", "LOGIC": "", "UI": ""}
    files_count = {"DB": 0, "LOGIC": 0, "UI": 0}

    for root, dirs, files in os.walk("."):
        # تجاهل المجلدات غير الضرورية
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
    # تحقق من أن الـ ID صحيح وليس Placeholder
    if not doc_id or "YOUR_" in doc_id:
        print(f"⚠️ Skipping update for undefined Doc ID: {doc_id}")
        return

    try:
        # 1. جلب حجم المستند الحالي
        doc = service.documents().get(documentId=doc_id).execute()
        content = doc.get('body').get('content', [])
        
        # الحصول على نهاية المستند (آخر فهرس)
        if not content:
            content_len = 0
        else:
            content_len = content[-1].get('endIndex')

        requests = []
        
        # 2. حذف المحتوى القديم (باستخدام الاسم الصحيح: deleteContentRange)
        # نحذف من المؤشر 1 حتى النهاية-1 (للحفاظ على نهاية الملف سليمة)
        if content_len > 2:
            requests.append({
                'deleteContentRange': {  # <--- التصحيح هنا
                    'range': {
                        'startIndex': 1,
                        'endIndex': content_len - 1
                    }
                }
            })

        # 3. التأكد من حجم النص لتجنب الأخطاء
        if len(new_content) > 1000000:
            print(f"⚠️ Content too large ({len(new_content)} chars), truncating...")
            new_content = new_content[:1000000] + "\n...[TRUNCATED]"

        # 4. إضافة المحتوى الجديد
        requests.append({
            'insertText': {
                'location': {'index': 1},
                'text': new_content if new_content else "(No content found)"
            }
        })

        # تنفيذ الطلب
        service.documents().batchUpdate(documentId=doc_id, body={'requests': requests}).execute()
        print(f"✅ Updated Doc ({doc_id}) successfully.")

    except Exception as e:
        print(f"❌ Failed to update doc {doc_id}: {e}")
# ==========================================
# 4. التشغيل الرئيسي
# ==========================================
def main():
    # الخطوة 1: توليد الكود من الملفات المحلية
    context_data = generate_project_context()
    
    # الخطوة 2: المصادقة ورفع البيانات
    print("\n🔑 Authenticating with Google...")
    try:
        creds = authenticate()
        service = build('docs', 'v1', credentials=creds)
        
        print("\n📤 Uploading to Google Docs...")
        for category, content in context_data.items():
            doc_id = DOCS_MAP.get(category)
            print(f"   -> Processing {category}...")
            update_google_doc(service, doc_id, content)
            
        print("\n🎉 All Done! Don't forget to click 'Sync' in NotebookLM.")
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        print("Make sure 'credentials.json' is present and correct.")

if __name__ == '__main__':
    main()