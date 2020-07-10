import os
import pickle
import ntpath

class get_olddata:

    def __init__(self):
        pass

    def find_filelist(self):
        __location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))

        f = open(os.path.join(__location__, 'test_file.txt'))
        New_path = f.read()
        f.close()

        os.chdir("..")

        Final_path = __location__ + '\\' + New_path
        os.chdir(Final_path)
        path = os.getcwd()

        OldlistOfFile = os.listdir(path=path)

        files = []
        # r=root, d=directories, f = files
        for r, d, f in os.walk(path):
            for file in f:
                files.append(os.path.join(r, file))


        os.chdir(__location__)
        f_file = open('temp.txt', 'w+')
        f_file.truncate(0)
        f_file.close()

        with open('temp.txt', 'wb') as filehandle:
            pickle.dump(OldlistOfFile, filehandle)
            pickle.dump(files, filehandle)
            print("Successfully written in text file")
        return files


if __name__ == '__main__':
    x = get_olddata()
    x.find_filelist()