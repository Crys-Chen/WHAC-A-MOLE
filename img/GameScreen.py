import cv2
import numpy as np

class Color():
    def __init__(self,
                 rgb: tuple # (R, G, B)
                ):
        self.RGB = (rgb[2], rgb[1], rgb[0])

game_screen = np.zeros((480, 800, 3), dtype=np.uint8)

background_color = Color((145, 181, 169))
cv2.rectangle(game_screen, (0, 0), (800, 480), background_color.RGB, 600)

top_left = (335, 15)
bottom_right = (785, 465)
color = Color((237, 202, 127))  
thickness = 16

cv2.rectangle(game_screen, top_left, bottom_right, color.RGB, thickness)
cv2.rectangle(game_screen, (top_left[0]+150, top_left[1]), (bottom_right[0]-150, bottom_right[1]), color.RGB, thickness)
cv2.rectangle(game_screen, (top_left[0], top_left[1]+150), (bottom_right[0], bottom_right[1]-150), color.RGB, thickness)

# mole = cv2.imread("mole.png", cv2.IMREAD_UNCHANGED)

# for x in range(0, 150):
#     for y in range(0, 150):
#         if mole[y, x, 3] > 0:
#             game_screen[y+15, x+335] = mole[y, x, 0:3]

delta = 80
# text_color = Color((217, 132, 129))
text_color = Color((50, 50, 50))
restart_color = Color((217, 132, 129))

cv2.putText(game_screen, 'SCORE: ', (30, delta), cv2.FONT_HERSHEY_COMPLEX, 1, text_color.RGB, 2, cv2.LINE_AA)
cv2.putText(game_screen, 'KILL: ', (30, 2*delta), cv2.FONT_HERSHEY_COMPLEX, 1, text_color.RGB, 2, cv2.LINE_AA)
cv2.putText(game_screen, 'RUNAWAY: ', (30, 3*delta), cv2.FONT_HERSHEY_COMPLEX, 1, text_color.RGB, 2, cv2.LINE_AA)
cv2.putText(game_screen, 'COMBO: ', (30, 4*delta), cv2.FONT_HERSHEY_COMPLEX, 1, text_color.RGB, 2, cv2.LINE_AA)
cv2.putText(game_screen, 'LEVEL: ', (30, 5*delta), cv2.FONT_HERSHEY_COMPLEX, 1, text_color.RGB, 2, cv2.LINE_AA)
cv2.putText(game_screen, '  RESTART ', (50, int(5.8*delta)), cv2.FONT_HERSHEY_COMPLEX, 1, text_color.RGB, 2, cv2.LINE_AA)
cv2.rectangle(game_screen, (70, int(5.4*delta)), (240, int(5.9*delta)), restart_color.RGB, 2)


# cv2.imshow('Game Screen', game_screen)
cv2.waitKey(0)
cv2.destroyAllWindows()

cv2.imwrite("GameScreen.jpg", game_screen)