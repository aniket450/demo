import os

def del_zip():
    __location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))

    f = open(os.path.join(__location__, 'test_file.txt'))
    New_path = f.read()
    f.close()
    os.chdir("..")
    Final_path = __location__ + '\\' + New_path

    test = os.listdir(Final_path)
    for item in test:
        if item.endswith(".zip"):
            print("Removing zip files:" + str(item))
            os.remove(os.path.join(Final_path, item))

del_zip()