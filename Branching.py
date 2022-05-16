var1 = float(input("give me two number: "))
var2 = float(input())

if (var1 + var2) >100:
    print("that is a big number")
elif var1 + var2 > 10:
    print("that is a mediocre number")
elif var1 + var2 > 5:
    print("that is a small number")
else:
    print("this is a very small number")
