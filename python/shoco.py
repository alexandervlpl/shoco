import os
import tempfile
import subprocess

shoco = os.path.join(os.path.dirname(os.path.abspath(__file__)), "shoco")
if not os.path.exists(shoco):
    raise Exception("Shoco binary not found, was it compiled?")

def compress(instr):
    fd, inpath = tempfile.mkstemp()
    outpath = tempfile.mkstemp()[1]
    
    infile = os.fdopen(fd, "wb")
    infile.write(instr.encode())
    infile.close()
    
    p = subprocess.run([shoco, "c", inpath, outpath])
    p.check_returncode()
    
    outfile = open(outpath, "rb")
    result = outfile.read()
    outfile.close()
    
    os.remove(inpath)
    os.remove(outpath)
    return result

def decompress(bytes_in):
    fd, inpath = tempfile.mkstemp()
    outpath = tempfile.mkstemp()[1]
    
    infile = os.fdopen(fd, "wb")
    infile.write(bytes_in)
    infile.close()
    
    p = subprocess.run([shoco, "d", inpath, outpath])
    p.check_returncode()
    
    outfile = open(outpath, "rb")
    result = outfile.read()
    outfile.close()
    
    os.remove(inpath)
    os.remove(outpath)
    return result

if __name__ == '__main__':
    import sys
    instr = sys.argv[1]
    c = compress(instr)
    d = decompress(c)
    print("%i > %i" % (len(instr.encode()), len(c)))
    sys.stdout.buffer.write(d)
    print()