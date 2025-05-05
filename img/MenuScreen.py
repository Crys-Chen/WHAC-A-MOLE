import cv2
import numpy as np

class Color():
    def __init__(self,
                 rgb: tuple # (R, G, B)
                ):
        self.RGB = (rgb[2], rgb[1], rgb[0])

menu_screen = np.zeros((480, 800, 3), dtype=np.uint8)

background_color = Color((145, 181, 169))
cv2.rectangle(menu_screen, (0, 0), (800, 480), background_color.RGB, 600)


delta = 80
text_color = Color((217, 132, 129))
start_color = Color((237, 202, 127)) 

cv2.putText(menu_screen, "WHAC-A-MOLE", (100, 180), cv2.FONT_HERSHEY_COMPLEX, 2.5, text_color.RGB, 6, cv2.LINE_AA)
cv2.putText(menu_screen, "TOUCH TO START", (190, 355), cv2.FONT_HERSHEY_COMPLEX, 1.5, start_color.RGB, 2, cv2.LINE_AA)
# cv2.rectangle(menu_screen, (70, int(5.4*delta)), (240, int(5.9*delta)), text_color.RGB, 2)

mole = cv2.imread("mole.png", cv2.IMREAD_UNCHANGED)

for x in range(0, 150):
    for y in range(0, 150):
        if mole[y, x, 3] > 0:
            menu_screen[y+190, x+10] = mole[y, x, 0:3]
        if mole[y, 149-x, 3] > 0:
            menu_screen[y+190, x+630] = mole[y, 149-x, 0:3]
        #     menu_screen[y+180, x+10] = mole[y, x, 0:3]


# cv2.imshow('Game Screen', menu_screen)
cv2.waitKey(0)
cv2.destroyAllWindows()

cv2.imwrite("MenuScreen.jpg", menu_screen)