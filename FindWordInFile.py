import os
from tkinter import *


class SearchWindow:
    def __init__(self):
        self.window = Tk()
        self.window.title("Find words in files")

    # Setter opp en liste som kan brukes for og holde styr på hvor mye man har letet gjennom         
        self.searched_items = [0,0,0]

    # Frame for input fields og button
        self.command_field = Frame(self.window)
        self.command_field.pack(pady = 10)

    # Input field for search location
        self.search_input_location = StringVar()
        self.search_location_box_text = Entry(self.command_field, textvariable = self.search_input_location, width = 100)
        self.search_location_box_text.insert(0, "Directory or filename")
        self.search_location_box_text.grid(column=1, row=1, padx = 5, ipady= 3)
        self.search_location_box_text.bind("<Button-1>", lambda event,  x = self.search_location_box_text: self.clear_text(x))

    # Input field for search word
        self.search_word = StringVar()
        self.search_word_box_text = Entry(self.command_field, textvariable = self.search_word, width = 60)     
        self.search_word_box_text.insert(0, "Search word")
        self.search_word_box_text.grid(column=2, row=1, padx = 5, ipady= 3)
        self.search_word_box_text.bind("<Button-1>", lambda event,  x = self.search_word_box_text: self.clear_text(x))

    # Search button
        self.search_button = Button(self.command_field, text = "Search", command = lambda: self.search_and_print(self.search_input_location.get()), width = 10)
        self.search_button.grid(column=3, row=1, padx = 5, ipady= 3)

    # Field brukt for tekst området og scroll bar
        self.text_area = Frame(self.window)
        self.text_area.pack()

    # Tekst området        
        self.print_field = Text(self.text_area, height = 35, width = 140)
        self.print_field.configure(state='disabled')
        self.print_field.pack(side = LEFT, padx = (10,0), pady = (0,10))

    # Scroll bar
        scrollbar = Scrollbar(self.text_area)
        scrollbar.pack(side = RIGHT, fill = Y, pady = (0,10))      
        scrollbar.config(command = self.print_field.yview)

        self.window.mainloop()


# Denne funksjonen kontrolerer hele search og print prosessen.
    def search_and_print(self, directory_path):
        self.start_text_print()
        self.restore()

    # Skjekker at man faktisk har søkt etter noe
        if len(self.search_word.get()) == 0:                                    
            self.print_text("Please enter a search word or character.\n")
        else:

    # Skjekker om search lokasjonen er en mappe eller en fil. Hvis mappe så legges en mappe til searched_items
            if os.path.isfile(self.search_input_location.get()) != True:        
                self.folder()

    # Prøver å kjøre search funksjonen, hvis det ikke går så printes en melding om at mappe lokasjonen ikke er riktig, setter så searched_items = [0,0,0]
            try:
                self.search(directory_path)
            except FileNotFoundError:
                self.print_text("The file could not be found, please check file path. \n")
                self.restore()
    
    # Kalle funksjon som printer slutt teksten
        self.end_text_print()


# Disse funksjonene hjelper å holde styr på hvor mange mapper og filer som har blitt letet gjennom
    def folder(self):
        self.searched_items[0] = self.searched_items[0] + 1
    def file(self):
        self.searched_items[1] = self.searched_items[1] + 1
    def hit(self):
        self.searched_items[2] = self.searched_items[2] + 1
    def restore(self):
        self.searched_items = [0,0,0]


# Disse 2 funksjonene printer linjer med tekst, de gjør dette ved hjelp av en egenutviklet print funksjon, se senere i koden
    def start_text_print(self):
        self.print_text("Search start.\n")
        self.print_text("------------------------------------------\n")

    def end_text_print(self):
        self.print_text("------------------------------------------\n")
        self.print_text("Search end.\n")
        self.print_text("Searched ")
        self.print_text(str(self.searched_items[0]))
        self.print_text(" directories and ")
        self.print_text(str(self.searched_items[1]))
        self.print_text(" files, found ")
        self.print_text(str(self.searched_items[2]))
        self.print_text(" occurances of \"")
        self.print_text(self.search_word.get().lower())
        self.print_text("\".\n\n\n")


# Search funksjonen, den leter gjennom innholdet i master_path, avgjør så om hver enkelt item er mappe eller fil. 
# Hvis fil tester den om den kan åpnes og leses som test fil, hvis ikke så printes en feilmelding.
# Kan den åpnes så kalles en funksjon som leter etter en linje som inneholder søkeordet. En fil legges til searched_items.
# Hvis item er en mappe, så legges en mappe til searched_items, så kalles funksjonen på nytt.
    def search(self, master_path):
        
        for sub_path in os.listdir(master_path):
            if os.path.isfile(master_path + "\\" + sub_path) == True:
                try:
                    self.file_word_search(master_path, sub_path)
                    self.file()
                except:
                    self.print_text("Could not open file " + master_path + "\\" + sub_path + ", as the file is not a text file.\n")
            else:
                self.folder()   
                self.search(master_path + "\\" + sub_path)
 

# Leter etter search word linje for linje, hvis search word finnes blir fil path og hele linjen printet. Skjekker som store og små bokstaver
    def file_word_search(self, master_path, sub_path):
        text_file = open(master_path + "\\" + sub_path, "r")

        for line in text_file:
            if self.search_word.get().lower() in line.lower():
                self.print_text(master_path + "\\" + sub_path + ":  --->  " + line + "\n")
                self.hit()        
        text_file.close()


# Funksjonen fjerner teksten som finnes i entry feltene nå man trykker i dem.
    def clear_text(self, x):
        x.delete(0, "end")


# Funksjon som gjør det lettere å printe ut data til print field i programmet.
# Den gjør først text feltet åpen for edditering, setter inn text så løses den for edditering.
    def print_text(self, text):
        self.print_field.configure(state='normal')
        self.print_field.insert(END, text)
        self.print_field.configure(state='disabled')

SearchWindow()