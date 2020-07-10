import os
import pickle
import ntpath
import shutil
import sys
import datetime
from time import gmtime, strftime

class extract_newfiles:

    def __init__(self):
        pass

    def get_files(self):
        current_path = os.getcwd()
        __location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))
        skip_name = 'MIL_Test.slx'
        skip_folder = 'testcase_MAT'

        zipname = sys.argv[1]
        # zipname = "Zipfile"
        if zipname is None:
            name = "Zipfile"
        else:
            name = zipname

        f = open(os.path.join(__location__, 'test_file.txt'))
        New_path = f.read()
        f.close()

        os.chdir("..")

        Final_path = __location__ + '\\' + New_path
        os.chdir(Final_path)
        path = os.getcwd()

        os.chdir(__location__)
        with open("temp.txt", "rb") as entity_file:
            Dirlevel = []
            Filelevel = []
            while True:
                try:
                    Dirlevel.append(pickle.load(entity_file))
                    Filelevel.append(pickle.load(entity_file))
                except EOFError:
                    break

        # Code to move directories from test folder to Backup folder
        NewlistOfFile = os.listdir(path=path)

        for skipDirlvl in NewlistOfFile:
            str_skipd = str(skipDirlvl)
            if skip_name in str_skipd or skip_folder in str_skipd:
                NewlistOfFile.remove(skipDirlvl)

        Newcontent = (list(set(NewlistOfFile) - set(Dirlevel[0])))
        #  current_directory = os.getcwd()
        final_directory = __location__ + '\\Backup'
        if not os.path.exists(final_directory):
            os.makedirs(final_directory)

        dir_src = path
        for x in Newcontent:
            dir_src = dir_src + '/' + str(x)
            shutil.move(dir_src, final_directory)
            dir_src = path
        print("Newly added Directories" + str(Newcontent))

        # Code to move new files from test folder to Backup folder
        new_files_names = []
        # r=root, d=directories, f = files
        for r, d, f in os.walk(str(path)):
            for file in f:
                new_files_names.append(os.path.join(r, file))

        new_added_files = []
        for m in (new_files_names):
            new_file = ntpath.basename(m)
            isthere = 0
            for n in (Filelevel[0]):
                old_file = ntpath.basename(n)
                if new_file == old_file:
                    isthere = 1;
                    break
                else:
                    isthere = 0
            if isthere == 0:
                if not skip_folder in m:
                  new_added_files.append(m)
            else:
                pass

        for item in new_added_files:    # To skip the MIL_Test.slx
            str_skipf = str(item)
            if skip_name in str_skipf or skip_folder in str_skipf:
                new_added_files.remove(str_skipf)

        print("Newly added Files"+str(new_added_files))

       # current_directory = os.getcwd()
        final_directory = __location__ + '\\Backup'
        if not os.path.exists(final_directory):
            os.makedirs(final_directory)

        for file in new_added_files:
            shutil.move(file, final_directory)

        if not os.listdir(final_directory):
            print("No new files or Dir found. No zipping")
        else:
            print("New Files are present. Done zipping")
            filename = str(path)+'/'+name + strftime("%Y-%m-%d__%H-%M-%S", gmtime())
            shutil.make_archive(filename, 'zip', str(final_directory))
            shutil.rmtree(final_directory, ignore_errors=True)



if __name__ == '__main__':
    x = extract_newfiles()
    x.get_files()