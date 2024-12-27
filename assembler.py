import argparse
import re
from enum import Enum
from typing import List

class OperandType(Enum):
    DEST = "dest"
    SRC1 = "src1"
    SRC2 = "src2"
    IMMEDIATE = "immediate"
    INDEX = "index"

class Instruction:
    def __init__(self, name, opcode, num_operands, operand_types, regex) -> None:
        self.name = name
        self.opcode = opcode
        self.num_operands = num_operands
        self.operand_types = [tuple(OperandType(op) for op in ops_tuple) for ops_tuple in operand_types]
        self.regex = re.compile(regex)  # to match operands

ISA = {
    # One Operand
    "NOP": Instruction("NOP", "00000", 0, [], ""),
    "HLT": Instruction("HLT", "00001", 0, [], ""),
    "SETC": Instruction("SETC", "00010", 0, [], ""),
    "NOT": Instruction("NOT", "00011", 2, [(OperandType.DEST,), (OperandType.SRC1,)], r" *R([0-7])\s*,\s*R([0-7])"),
    "INC": Instruction("INC", "00100", 2, [(OperandType.DEST,), (OperandType.SRC1,)], r" *R([0-7])\s*,\s*R([0-7])"),
    "OUT": Instruction("OUT", "00101", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "IN": Instruction("IN", "00110", 1, [(OperandType.DEST,)], r" *R([0-7])"),
    
    # Two Operands
    "MOV": Instruction("MOV", "01000", 2, [(OperandType.DEST,), (OperandType.SRC1,)], r" *R([0-7])\s*,\s*R([0-7])"),
    "ADD": Instruction("ADD", "01001", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-7])\s*,\s*R([0-7])\s*,\s*R([0-7])"),
    "SUB": Instruction("SUB", "01010", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-7])\s*,\s*R([0-7])\s*,\s*R([0-7])"),
    "AND": Instruction("AND", "01011", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.SRC2,)], r" *R([0-7])\s*,\s*R([0-7])\s*,\s*R([0-7])"),
    "IADD": Instruction("IADD", "01100", 3, [(OperandType.DEST,), (OperandType.SRC1,), (OperandType.IMMEDIATE,)], r" *R([0-7])\s*,\s*R([0-7])\s*,\s*([0-9A-F]+)"),
    
    # Memory Operations
    "PUSH": Instruction("PUSH", "10000", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "POP": Instruction("POP", "10001", 1, [(OperandType.DEST,)], r" *R([0-7])"),
    "LDM": Instruction("LDM", "10010", 2, [(OperandType.DEST,), (OperandType.IMMEDIATE,)], r" *R([0-7])\s*,\s*([0-9A-F]+)"),
    "LDD": Instruction("LDD", "10011", 3, [(OperandType.DEST,), (OperandType.IMMEDIATE,), (OperandType.SRC1,)], r" *R([0-7])\s*,\s*([0-9][0-9A-F]*)\s*\(\s*R([0-7])\s*\)"),
    "STD": Instruction("STD", "10100", 3, [(OperandType.SRC1,), (OperandType.IMMEDIATE,), (OperandType.SRC2,)], r" *R([0-7])\s*,\s*([0-9][0-9A-F]*)\s*\(\s*R([0-7])\s*\)"),
   
    # Branch and change of control 
    "JZ": Instruction("JZ", "11000", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "JN": Instruction("JN", "11001", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "JC": Instruction("JC", "11010", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "JMP": Instruction("JMP", "11011", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "CALL": Instruction("CALL", "11100", 1, [(OperandType.SRC1,)], r" *R([0-7])"),
    "RET": Instruction("RET", "11101", 0, [], ""),
    "INT": Instruction("INT", "11110", 1, [(OperandType.INDEX,)], r" *([0-1])"),
    "RTI": Instruction("RTI", "11111", 0, [], ""),

    # Special
    ".ORG": Instruction(".ORG", "", 0, [(OperandType.IMMEDIATE,)], r" [0-9][0-9A-F]*")
}


def decimal_to_binary(n, size):
    res = bin(int(str(n), 10))[2:]
    assert(len(res) <= size)
    return res.zfill(size)

def hex_to_binary(n, size = 16):
    res = bin(int(str(n), 16))[2:]
    assert(len(res) <= 16)
    return res.zfill(size)


def assembler(lines):
    """
        This will take lines and output a list of address-instruction pairs

    Args:
        lines (list[str]): lines in the .asm file
    """
    instructions = []
    org = 0
    is_value = re.compile(r"^ *([0-9A-F]{1,4})(?: *)?$")
    for i,line in enumerate(lines):

        # Skip comment, Take the instrutcion without the comment
        idx = line.find("#")
        if idx != -1:
            line = line[:idx]
        line = line.upper()
        line = line.strip()
        if len(line) == 0: continue

        if is_value.findall(line): # Value after .org hex or decimal?
            instructions.append((org, hex_to_binary(line, 16)))
            org += 1
            continue
        name = line.split(" ")[0]

        # if inst not in ISA
        if name not in ISA:
            print(f"Error at line {i + 1}: Instruction {name} not found")
            exit(1)
        

        if ISA[name].name == ".ORG": # is org
            org = int(ISA[name].regex.findall(line)[0], 16)
            continue

        tr_line = ISA[name].opcode
        dest = "000"
        src1 = "000"
        src2 = "000"
        imm = "0000000000000000"
        isImm = "0"
        index = "0"
        matches = ISA[name].regex.findall(line)[0]
        for i,match in enumerate(matches):
            for opType in ISA[name].operand_types[i]:
                if opType == OperandType.DEST:
                    dest = decimal_to_binary(match, 3)

                elif opType == OperandType.SRC1:
                    src1 = decimal_to_binary(match, 3)

                elif opType == OperandType.SRC2:
                    src2 = decimal_to_binary(match, 3)

                elif opType == OperandType.INDEX:
                    index = match

                else:
                    isImm = "1"
                    imm = hex_to_binary(match, 16)

        tr_line += src1 + src2 + dest +isImm + index
        instructions.append((org, tr_line))
        org += 1
        if isImm == "0": continue
        instructions.append((org, imm))
        org += 1
    return instructions


def write_instructions(instructions):
    """
    Takes in instructions lines and produces .mem file lines

    Args:
        instructions (list[tuple]): list of instructions lines
    """
    output = []
    output.append("// memory data file (do not edit the following line - required for mem load use)\n")
    output.append("// instance=/processor/Fetch_Unit_Inst/Instruction_Memory_Inst/memory\n")
    output.append("// format=mti addressradix=d dataradix=b version=1.0 wordsperline=1\n")
    code_lines = ["{:>{width}}: 0000000000000000\n".format(i, width=4) for i in range(4096)]
    for address,line in instructions:
        splitted = code_lines[address].split(": ")
        code_lines[address] = splitted[0] + ": " + line + "\n"
    output.extend(code_lines)
    return output

def process_file(file_path, output_path):
    with open(file_path, "r") as file:
        lines = file.readlines()
    instructions = assembler(lines)
    output = write_instructions(instructions)
    with open(output_path, "w") as f:
        f.writelines(output)


def main():
    argparser = argparse.ArgumentParser()
    argparser.add_argument("--file", "-F", dest="file_path", default="./asm_example.asm", help="Path to the file to process")
    argparser.add_argument("--output", "-O", dest="output_file", default="./instructions.mem", help="Output path")
    args = argparser.parse_args()
    process_file(args.file_path, args.output_file)

if __name__ == "__main__":
    main()