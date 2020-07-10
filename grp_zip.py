import os
import shutil

def grp_zip():
    __location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))

    f = open(os.path.join(__location__, 'test_file.txt'))
    New_path = f.read()
    f.close()
    os.chdir("..")
    Final_path = __location__ + '\\' + New_path
    final_directory = Final_path + '\\Deliverables'
    if not os.path.exists(final_directory):
        os.makedirs(final_directory)

    dir_src = Final_path
    test = os.listdir(Final_path)
    for item in test:
        if item.endswith(".zip"):
            dir_src = dir_src + '/' + str(item)
            print("Moving zip files:" + str(item))
            shutil.move(dir_src, final_directory)
            dir_src = Final_path

grp_zip()