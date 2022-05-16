var1 = int(input("Type in a number: "))
var2 = int(input("Type in another number: "))

if var1 + var2 > 100:
    print("That is a big number")
elif var1 + var2 > 10:
    print("That is a mediocre number")
elif var1 + var2 > 5:
    print("That is a small number")
elif var1 + var2 < 5:
    print("That is a very small number")
else:
    print("error")
