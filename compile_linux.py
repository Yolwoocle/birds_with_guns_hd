import os
import datetime as dt

def ask_for_input(msg, values):
    inp = ''
    while not inp in values:
        inp = input(msg)
    return inp

today = str(dt.date.today()) 
y, m, d = today.split("-")
gamename = f'birdswithguns_v0_{y[2:]}-{m}-{d}'

platform = ask_for_input('Platform [w,m,l]: ', ('w','m','l'))
if platform == 'w':
    if not os.path.isdir(f'export'):
        os.system(f'mkdir export')
    if not os.path.isdir(f'export/{gamename}'):
        os.system(f'mkdir export/{gamename}')
    os.system(f'zip -9 -r {gamename}.love . -x ".git/*" -x ".vscode/*"')
    os.system(f'mv {gamename}.love export/{gamename}/')

    if os.path.isdir('love_win'):
        os.system(f'cp love_win/SDL2.dll export/{gamename}/')
        os.system(f'cp love_win/OpenAL32.dll export/{gamename}/')
        os.system(f'cp love_win/license.txt export/{gamename}/')
        os.system(f'cp love_win/love.dll export/{gamename}/')
        os.system(f'cp love_win/lua51.dll export/{gamename}/')
        os.system(f'cp love_win/mpg123.dll export/{gamename}/')
        os.system(f'cp love_win/msvcp120.dll export/{gamename}/')
        os.system(f'cp love_win/msvcr120.dll export/{gamename}/')
    else:
        print("ERROR: please define a love_win folder and unzip the official LÖVE executable: https://www.love2d.org/")