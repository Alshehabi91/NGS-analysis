number1 = int(input("Number1: "))
number2 = int(input("Number2: "))
number3 = int(input("Number3: "))
number4 = int(input("Number4: "))
number5 = int(input("Number5: "))
number6 = int(input("Number6: "))

print("choose 1 for addition")
print("choose 2 for division")
print("choose 3 for subtraction")

choice = int(input("waht operation do you want to run? "))
if choice == 1:
    result1 = number2 + number4
    print(result1)
elif choice == 2:
    result2 = number1 / number3
    print(result2)
elif choice == 3:
    result3 = number5 - number6
    print(result3)
else:
    print("wrong choice")
