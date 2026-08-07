# Look at lcl_dao types
import sys
with open('Spec and result/ZCL_APS_Z8_PREDICTED_DATES_I.txt', 'r') as f:
    lines = f.readlines()
    for i, line in enumerate(lines):
        if 'TYPES: tt_bal_msg_sorted' in line:
            print(f"Line {i+1}: {line.strip()}")
