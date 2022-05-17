lis1 = list(range(5,10))
lis2 =list(range(10,20))

print(lis1)
print(lis2)

choice1 = int(input("Give me a first number: "))
choice2 = int(input("Give me a second number: "))
choice3 = int(input("Give me a third number: "))
choice4 = int(input("Give me a fourt number: "))

if choice1 > len(lis1) or choice1 > len(lis2):
    print("Give me smaller number please: ")
elif choice2 > len(lis1) or choice2 > len(lis2):
    print("Give me smaller number please: ")
else:
    print(lis1[choice1:choice2])
