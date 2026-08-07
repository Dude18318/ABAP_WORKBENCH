import re

def process():
    file_path = "Spec and result/ZCL_APS_Z8_PREDICTED_DATES_I.txt"
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # We need to extract CLASS lcl_dao DEFINITION and IMPLEMENTATION.
    # The file has a comment block starting with:
    # *"* use this source file for the definition and implementation of
    # *"* local helper classes, interface definitions and type
    # *"* declarations

    parts = content.split('*"* use this source file for the definition and implementation of')
    if len(parts) == 2:
        main_class_part = parts[0].strip()
        local_class_part = '*"* use this source file for the definition and implementation of' + parts[1]

        # We'll put local classes at the top
        new_content = local_class_part.strip() + "\n\n" + main_class_part + "\n"

        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print("Success: Moved local classes to the top.")
    else:
        print("Error: Could not split file as expected.")

process()
