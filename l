import pygame
from pygame import mixer
from fighter import Fighter

mixer.init()
pygame.init()

# Create game window
SCREEN_WIDTH = 1400  # Increased width
SCREEN_HEIGHT = 800  # Increased height

screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Brawler")

# Set framerate
clock = pygame.time.Clock()
FPS = 60

# Define colours
RED = (255, 0, 0)
YELLOW = (255, 255, 0)
WHITE = (255, 255, 255)
BLACK = (0, 0, 0)

# Define game variables
intro_count = 3
last_count_update = pygame.time.get_ticks()
score = [0, 0]  # player scores. [P1, P2]
round_over = False
ROUND_OVER_COOLDOWN = 2000

# Define fighter variables
WARRIOR_SIZE = 162
WARRIOR_SCALE = 4
WARRIOR_OFFSET = [72, 56]
WARRIOR_DATA = [WARRIOR_SIZE, WARRIOR_SCALE, WARRIOR_OFFSET]
WIZARD_SIZE = 250
WIZARD_SCALE = 3
WIZARD_OFFSET = [112, 107]
WIZARD_DATA = [WIZARD_SIZE, WIZARD_SCALE, WIZARD_OFFSET]

# Load music and sounds
pygame.mixer.music.load("assets/audio/music.mp3")
pygame.mixer.music.set_volume(0.5)
pygame.mixer.music.play(-1, 0.0, 5000)
sword_fx = pygame.mixer.Sound("assets/audio/sword.wav")
sword_fx.set_volume(0.5)
magic_fx = pygame.mixer.Sound("assets/audio/magic.wav")
magic_fx.set_volume(0.75)

# Load background image
bg_image = pygame.image.load("assets/images/background/background.jpg").convert_alpha()

# Load spritesheets
warrior_sheet = pygame.image.load("assets/images/warrior/Sprites/warrior.png").convert_alpha()
wizard_sheet = pygame.image.load("assets/images/wizard/Sprites/wizard.png").convert_alpha()

# Load victory image
victory_img = pygame.image.load("assets/images/icons/victory.png").convert_alpha()

# Define number of steps in each animation
WARRIOR_ANIMATION_STEPS = [10, 8, 1, 7, 7, 3, 7]
WIZARD_ANIMATION_STEPS = [8, 8, 1, 8, 8, 3, 7]

# Define font
count_font = pygame.font.Font("assets/fonts/turok.ttf", 80)
score_font = pygame.font.Font("assets/fonts/turok.ttf", 30)
menu_font = pygame.font.Font("assets/fonts/turok.ttf", 60)

# Function for drawing text
def draw_text(text, font, text_col, x, y):
    img = font.render(text, True, text_col)
    screen.blit(img, (x, y))

# Function for drawing background
def draw_bg():
    scaled_bg = pygame.transform.scale(bg_image, (SCREEN_WIDTH, SCREEN_HEIGHT))
    screen.blit(scaled_bg, (0, 0))

# Function for drawing fighter health bars
def draw_health_bar(health, x, y):
    ratio = health / 100
    pygame.draw.rect(screen, WHITE, (x - 2, y - 2, 404, 34))
    pygame.draw.rect(screen, RED, (x, y, 400, 30))
    pygame.draw.rect(screen, YELLOW, (x, y, 400 * ratio, 30))

# Function to create fighters
def create_fighters():
    fighter_1 = Fighter(1, 150, 410, False, WARRIOR_DATA, warrior_sheet, WARRIOR_ANIMATION_STEPS, sword_fx)  # Adjusted y position
    fighter_2 = Fighter(2, 850, 410, True, WIZARD_DATA, wizard_sheet, WIZARD_ANIMATION_STEPS, magic_fx)  # Adjusted x position
    return fighter_1, fighter_2

# Function to display the menu with buttons
def show_menu():
    while True:
        screen.fill(WHITE)
        draw_bg()  # Draw the background

        draw_text("Brawler", menu_font, RED, SCREEN_WIDTH / 2 - 150, SCREEN_HEIGHT / 3)

        # Draw buttons
        start_button_rect = pygame.Rect(SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2 - 40, 200, 80)
        quit_button_rect = pygame.Rect(SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT / 2 + 60, 200, 80)

        # Draw button background and border
        pygame.draw.rect(screen, BLACK, start_button_rect, 3)  # Thicker Border
        pygame.draw.rect(screen, RED, start_button_rect)  # Background
        draw_text("Start", menu_font, WHITE, SCREEN_WIDTH / 2 - 50, SCREEN_HEIGHT / 2 - 30)

        pygame.draw.rect(screen, BLACK, quit_button_rect, 3)  # Thicker Border
        pygame.draw.rect(screen, RED, quit_button_rect)  # Background
        draw_text("Quit", menu_font, WHITE, SCREEN_WIDTH / 2 - 50, SCREEN_HEIGHT / 2 + 70)

        pygame.display.update()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_q:
                    pygame.quit()
                    exit()
                if event.key == pygame.K_s:  # Press 'S' to start
                    return  # Start the game
            if event.type == pygame.MOUSEBUTTONDOWN:
                if event.button == 1:  # Left mouse button
                    if start_button_rect.collidepoint(event.pos):
                        return  # Start the game
                    if quit_button_rect.collidepoint(event.pos):
                        pygame.quit()
                        exit()

# Game loop
run = True
while run:
    show_menu()  # Show menu before starting the game

    # Reset game variables for new game
    intro_count = 3
    last_count_update = pygame.time.get_ticks()
    score = [0, 0]
    round_over = False
    fighter_1, fighter_2 = create_fighters()  # Create fighters

    paused = False  # Variable to track pause state

    while not round_over:
        clock.tick(FPS)

        # Event handling for quitting the game during the game
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                pygame.quit()
                exit()
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_p:  # Toggle pause on 'P' key
                    paused = not paused

        if paused:
            # Show pause screen
            screen.fill(WHITE)
            draw_text("Paused", menu_font, RED, SCREEN_WIDTH / 2 - 150, SCREEN_HEIGHT / 3)
            draw_text("Press 'P' to Resume", score_font, RED, SCREEN_WIDTH / 2 - 200, SCREEN_HEIGHT / 2)
            draw_text("Press 'Q' to Quit", score_font, RED, SCREEN_WIDTH / 2 - 200, SCREEN_HEIGHT / 2 + 100)
            pygame.display.update()
            continue  # Skip the rest of the loop if paused

        # Draw background
        draw_bg()

        # Show player stats
        draw_health_bar(fighter_1.health, 20, 20)
        draw_health_bar(fighter_2.health, 680, 20)  # Adjusted x position
        draw_text("P1: " + str(score[0]), score_font, RED, 20, 60)
        draw_text("P2: " + str(score[1]), score_font, RED, 680, 60)  # Adjusted x position

        # Update countdown
        if intro_count <= 0:
            # Move fighters
            fighter_1.move(SCREEN_WIDTH, SCREEN_HEIGHT, screen, fighter_2, round_over)
            fighter_2.move(SCREEN_WIDTH, SCREEN_HEIGHT, screen, fighter_1, round_over)
        else:
            # Display count timer
            draw_text(str(intro_count), count_font, RED, SCREEN_WIDTH / 2, SCREEN_HEIGHT / 3)
            # Update count timer
            if (pygame.time.get_ticks() - last_count_update) >= 1000:
                intro_count -= 1
                last_count_update = pygame.time.get_ticks()

        # Update fighters
        fighter_1.update()
        fighter_2.update()

        # Draw fighters
        fighter_1.draw(screen)
        fighter_2.draw(screen)

        # Check for player defeat
        if not fighter_1.alive:
            score[1] += 1
            round_over = True
            round_over_time = pygame.time.get_ticks()
        elif not fighter_2.alive:
            score[0] += 1
            round_over = True
            round_over_time = pygame.time.get_ticks()

        if round_over:
            # Display victory image
            screen.blit(victory_img, (520, 250))  # Centered on the screen
            pygame.display.update()
            pygame.time.delay(ROUND_OVER_COOLDOWN)

        # Update display
        pygame.display.update()

# Exit pygame
pygame.quit()
