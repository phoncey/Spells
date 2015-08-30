#!/usr/bin/python

import re
import sys

def fileFindAndReplace():
    if(len(sys.argv) == 1):
        useage()
        exit()
    filename = str(sys.argv[1])
    find_string = str(sys.argv[2])
    replace_string = str(sys.argv[3])
    
    file = open(filename, 'r')
    fileContents = file.read()
    file.close()
    replacer = re.compile(find_string)
    fileContents = replacer.sub(replace_string, fileContents)
    print("File contents are: %s" % fileContents)
    
    file = open(filename, 'w')
    file.write(fileContents)
    file.close()
    
def useage():
    print("Usesage: FindReplace.py <filename> <find_string> <replace_string>")

def main():
    print("Find and replace in File!")
    fileFindAndReplace()

if __name__ == "__main__":
    main()