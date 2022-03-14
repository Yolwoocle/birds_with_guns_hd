import os
import datetime as dt

def ask_for_input(msg, values):
    inp = ''
    while not inp in values:
        inp = input(f'{msg} {tuple(values)}: ')
    return inp

def mkdir(dir):
    if not os.path.isdir(f'{dir}'):
        os.system(f'mkdir {dir}')


today = str(dt.date.today()) 
y, m, d = today.split("-")
gamename = f'birdswithguns_v0_{y[2:]}-{m}-{d}'

platform = ask_for_input('Platform', ("win32","win64","macos","linux"))
if platform == 'win64':
    path_love_win64 = 'love_win_64'
    path_exportdir = f'export/{gamename}'
    path_export_win64 = f'export/{gamename}/win64'

    # Zip into a .love
    print("Generating .love...")
    os.system(f'zip -9 -r {gamename}.love . -x ".git/*" -x ".vscode/*"')

    # Export dirs
    mkdir('export')
    mkdir(f'export/{gamename}')
    mkdir(f'export/{gamename}/win64')
    if os.path.isdir(path_love_win64):
        # cat to a .exe
        print("Generating .exe...")
        os.system(f'cat {path_love_win64}/love.exe {gamename}.love > {gamename}.exe')
        os.system(f'mv {gamename}.exe {path_export_win64}/')
        os.system(f'rm {gamename}.love')

        # Copy dependencies
        print("Copying dependencies...")
        os.system(f'cp {path_love_win64}/SDL2.dll {path_export_win64}/')
        os.system(f'cp {path_love_win64}/OpenAL32.dll {path_export_win64}/')
        os.system(f'cp {path_love_win64}/license.txt {path_export_win64}/')
        os.system(f'cp {path_love_win64}/love.dll {path_export_win64}/')
        os.system(f'cp {path_love_win64}/lua51.dll {path_export_win64}/')
        os.system(f'cp {path_love_win64}/mpg123.dll {path_export_win64}/')
        os.system(f'cp {path_love_win64}/msvcp120.dll {path_export_win64}/')
        os.system(f'cp {path_love_win64}/msvcr120.dll {path_export_win64}/')
        
        # Zip
        print("Zipping game directory...")
        os.system(f'zip -r {path_exportdir}/{gamename}_win_64.zip {path_export_win64}')
        os.system(f'mv {gamename}_win_64.zip {path_exportdir}')
    else:
        print("ERROR: please define a love_win_64 folder and unzip the official LÖVE executable: https://www.love2d.org/")
        
print("Done")