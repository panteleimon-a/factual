import tkinter as tk

text = tk.Tk()

canvas1 = tk.Canvas(text, width=400, height=300)
canvas1.pack()

entry1 = tk.Entry(text)
canvas1.create_window(200, 140, window=entry1)


def get_tweet_fact_score():
#   Here we should add all the code. In the {text=x1 + '1'} the final score should be added  #
    x1 = entry1.get()
    label1 = tk.Label(text, text=x1 + '1')
    canvas1.create_window(200, 230, window=label1)


button1 = tk.Button(text='Import the tweet text and calculate its fact score!', command=get_tweet_fact_score)
canvas1.create_window(200, 180, window=button1)

text.mainloop()
