def my_function(arg1, arg2, function_behavior):
    if function_behavior == 1:
        print(arg1)
    elif function_behavior == 2:
        print(arg2)
    else:
        print('none')


if __name__ == "__main__":
    my_function('argument 1', 1231, 1)

    my_function('arg2', 0x255, 2)

    my_function('parameter 3', -1, 3)
