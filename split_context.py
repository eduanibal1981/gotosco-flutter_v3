import os

# إعدادات المخرجات (أين سيتم حفظ كل نوع من الكود)
OUTPUT_FILES = {
    "DB": "Context_Database_Schema.txt",
    "LOGIC": "Context_Logic_Core.txt",
    "UI": "Context_UI_Components.txt"
}

# قواعد التصنيف (تعتمد على هيكلية مشروعك)
def get_category(file_path):
    path = file_path.replace("\\", "/") # توحيد الفواصل
    
    # 1. قاعدة البيانات (SQL + Schema)
    if "supabase/" in path and path.endswith(".sql"):
        return "DB"
    
    # تجاهل الملفات غير المهمة
    if not path.endswith((".dart", ".sql")):
        return None
    if "generated" in path or ".g.dart" in path or ".freezed.dart" in path:
        return None # تقليل الضوضاء (اختياري)

    # 2. المنطق (Logic & Core)
    # يشمل: Repositories, Models, Controllers, Services, Core Utilities
    if (
        "/data/" in path or 
        "/models/" in path or 
        "_repository.dart" in path or 
        "_controller.dart" in path or 
        "_service.dart" in path or
        "_provider.dart" in path or
        "lib/core/" in path and "widgets" not in path # Core logic excluding widgets
    ):
        return "LOGIC"

    # 3. واجهة المستخدم (UI)
    # يشمل: Screens, Widgets, Tabs, Views
    if (
        "/presentation/" in path or 
        "/widgets/" in path or 
        "_screen.dart" in path or 
        "_tab.dart" in path or
        "_view.dart" in path
    ):
        return "UI"

    return None

def main():
    # تفريغ الملفات القديمة قبل البدء
    for key in OUTPUT_FILES:
        with open(OUTPUT_FILES[key], "w", encoding="utf-8") as f:
            f.write(f"=== {key} CONTEXT FILE ===\n\n")

    # البدء في مسح المشروع
    print("Starting context generation...")
    
    files_processed = {"DB": 0, "LOGIC": 0, "UI": 0}

    for root, dirs, files in os.walk("."):
        # استثناء المجلدات غير المرغوبة
        if any(ignore in root for ignore in [".git", "build", ".dart_tool", "ios", "android", "web", "linux", "windows", "test"]):
            continue
            
        for file in files:
            file_path = os.path.join(root, file)
            category = get_category(file_path)
            
            if category:
                try:
                    with open(file_path, "r", encoding="utf-8") as infile:
                        content = infile.read()
                        
                    # تنسيق الكود داخل ملف السياق
                    formatted_content = (
                        f"\n{'='*60}\n"
                        f"FILE PATH: {file_path}\n"
                        f"{'='*60}\n"
                        f"{content}\n"
                    )
                    
                    # الكتابة في الملف المناسب
                    with open(OUTPUT_FILES[category], "a", encoding="utf-8") as outfile:
                        outfile.write(formatted_content)
                        
                    files_processed[category] += 1
                    print(f"[{category}] Added: {file_path}")
                    
                except Exception as e:
                    print(f"Skipping {file_path}: {e}")

    print("\nDone! Summary:")
    for key, count in files_processed.items():
        print(f"{key}: {count} files -> {OUTPUT_FILES[key]}")

if __name__ == "__main__":
    main()