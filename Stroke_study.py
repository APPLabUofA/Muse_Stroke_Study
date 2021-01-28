import time
import os

###create a dummy display for pygame###
#os.environ['SDL_VIDEODRIVER'] = 'dummy'

import sys
from random import randint
from random import shuffle
from datetime import datetime
import numpy as np
import pandas as pd
import pygame
from pylsl import StreamInfo, StreamOutlet, local_clock

###create our stream variables###
info = StreamInfo('Markers', 'Markers', 1, 0, 'int32', 'myuidw43536')

###next make an outlet to record the streamed data###
outlet = StreamOutlet(info)

###initialise pygame###
pygame.mixer.pre_init(44100,-16,2,1024)
pygame.init()
pygame.display.set_mode((1,1))
pygame.mixer.init()

display_info = pygame.display.Info()
screen = pygame.display.set_mode((640,480))
disp_info = pygame.display.Info()
screen = pygame.display.set_mode((disp_info.current_w, disp_info.current_h),pygame.FULLSCREEN)
x_center = disp_info.current_w/2
y_center = disp_info.current_h/2
black = pygame.Color(0, 0, 0)
white = pygame.Color(255,255,255)

screen.fill(pygame.Color("black"))
pygame.draw.line(screen, (255, 255, 255), (x_center-10, y_center), (x_center+10, y_center),4)
pygame.draw.line(screen, (255, 255, 255), (x_center, y_center-10), (x_center, y_center+10),4)
pygame.display.flip()
pygame.mouse.set_visible(0)

###variables for filenames and save locations###
partnum = '001'
device = 'Muse'
filename = 'Baseline_Stroke_Study_Updated'
exp_loc = 'Baseline_Stroke_Study'
date = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

###time for each baseline segment###
baseline_length = 60 ###3 minutes in seconds

###create variables for our sounds###
tone= '/Users/mathlab/muse_exp/Experiments/Stimuli/Sounds/Auditory_Oddball/1000hz_tone.wav'
ready_tone= '/Users/mathlab/muse_exp/Experiments/Stimuli/Sounds/Auditory_Oddball/2000hz_tone.wav'

###setup variables to record times###
exp_start = []
trig_time   = []

###play tones to indicate the experiment is ready###
pygame.mixer.music.load(ready_tone)
for i_tone in range(2):
    pygame.mixer.music.play()
    while pygame.mixer.music.get_busy() == True:
        continue

###wait for button press to start experiment###
key_pressed = 0
pygame.event.clear()
while key_pressed == 0:
    event = pygame.event.wait()
    if event.type == pygame.QUIT:
        pygame.quit()
        sys.exit()
    elif event.type == pygame.KEYDOWN:
        if event.key == pygame.K_SPACE:
            key_pressed = 1

###send triggers###
exp_start = time.time()
trig_time.append(time.time() - exp_start)
timestamp = time.time()
outlet.push_sample([1], timestamp)

###play tones at the beginning to indicate start of first three minute segment###
pygame.mixer.music.load(tone)
for i_tone in range(3):
    pygame.mixer.music.play()
    while pygame.mixer.music.get_busy() == True:
        continue
    time.sleep(0.1)

###send triggers###
trig_time.append(time.time() - exp_start)
timestamp = time.time()
outlet.push_sample([2], timestamp)

###now wait the first three minutes
time.sleep(baseline_length)

###send triggers###
trig_time.append(time.time() - exp_start)
timestamp = time.time()
outlet.push_sample([3], timestamp)

###now play the tones again to indicate the end of the first segment and the beginning of the next###
pygame.mixer.music.load(tone)
for i_tone in range(3):
    pygame.mixer.music.play()
    while pygame.mixer.music.get_busy() == True:
        continue
    time.sleep(0.1)

###wait for button press to start experiment###
key_pressed = 0
pygame.event.clear()
while key_pressed == 0:
    event = pygame.event.wait()
    if event.type == pygame.QUIT:
        pygame.quit()
        sys.exit()
    elif event.type == pygame.KEYDOWN:
        if event.key == pygame.K_SPACE:
            key_pressed = 1

###send triggers###
trig_time.append(time.time() - exp_start)
timestamp = time.time()
outlet.push_sample([4], timestamp)

###now play the tones again to indicate the end of the first segment and the beginning of the next###
pygame.mixer.music.load(tone)
for i_tone in range(3):
    pygame.mixer.music.play()
    while pygame.mixer.music.get_busy() == True:
        continue
    time.sleep(0.1)

###send triggers###
trig_time.append(time.time() - exp_start)
timestamp = time.time()
outlet.push_sample([5], timestamp)

###now wait the second three minutes
time.sleep(baseline_length)

###send triggers###
trig_time.append(time.time() - exp_start)
timestamp = time.time()
outlet.push_sample([6], timestamp)

###play the tones to indicate the end of the experiment###
pygame.mixer.music.load(tone)
for i_tone in range(3):
    pygame.mixer.music.play()
    while pygame.mixer.music.get_busy() == True:
        continue
    time.sleep(0.1)

###send triggers###
trig_time.append(time.time() - exp_start)
timestamp = time.time()
outlet.push_sample([7], timestamp)

###save times###
while os.path.isfile("/Users/mathlab/muse_exp/Experiments/" + exp_loc + "/Data/" + device + "/LSL_Trial_Information/" + partnum + "_" + filename + ".csv") == True:
    if int(partnum) >=10:
        partnum = "0" + str(int(partnum) + 1)
    else:
        partnum = "00" + str(int(partnum) + 1)

filename_part = ("/Users/mathlab/muse_exp/Experiments/" + exp_loc + "/Data/" + device + "/LSL_Trial_Information/" + partnum + "_" + filename + ".csv")

the_list = [date,trig_time]
df_list = pd.DataFrame({i:pd.Series(value) for i, value in enumerate(the_list)})
df_list.columns = ['Date','Baseline_Onset_Offset_Time']
df_list.to_csv(filename_part)

pygame.display.quit()
pygame.quit()

if os.path.isfile("/Users/mathlab/muse_exp/Experiments/Stop_EEG2.csv") == True:
    os.remove("/Users/mathlab/muse_exp/Experiments/Stop_EEG2.csv")
    os.remove("/Users/mathlab/muse_exp/Experiments/Stop_EEG1.csv")
    time.sleep(5.0)
