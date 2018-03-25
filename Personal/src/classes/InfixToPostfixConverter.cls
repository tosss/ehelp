public class InfixToPostfixConverter 
{
	public static String infixExpression = '1*3+5/2';
    public static Boolean association = false; //left To right
    public static String infixToPostfix()
    {
        String output = '';
        String stack = '';
        for(Integer i=0; i < infixExpression.length(); i++)
        {
            Integer asciiValue = infixExpression.charAt(i);
            String character = String.fromCharArray(new List<Integer>{asciiValue});
            Integer stackTopAscii;
            String stackTop;
            if(stack != '' && !String.isEmpty(stack))
            {
                stackTopAscii = stack.charAt(stack.length()-1);
                stackTop = String.fromCharArray(new List<Integer>{stackTopAscii});
            }
            if(character.isNumeric())
            {
                output += character;
            }
            else if(String.isEmpty(stack) || stack == '' || character == '(' || precedence(stackTop) < precedence(character))
            {
                stack += character;
            }
            else if(character == ')')
            {
                while(stackTop != '(')
                { 
                    output += stackTop;
                    stack = stack.removeEnd(stackTop);
                    stackTopAscii = stack.charAt(stack.length()-1);
                    stackTop = String.fromCharArray(new List<Integer>{stackTopAscii});
                }
                stack = stack.removeEnd(stackTop);
            }
            else if(precedence(stackTop) == precedence(character))
            {
                output += stackTop;
                stack = stack.removeEnd(stackTop);
                stack += character;
            }
            else if(precedence(stackTop) > precedence(character))
            {
                while(precedence(stackTop) > precedence(character))
                { 
                    output += stackTop;
                    stack = stack.removeEnd(stackTop);
                    if(stack != '')
                    {
                        stackTopAscii = stack.charAt(stack.length()-1);
                        stackTop = String.fromCharArray(new List<Integer>{stackTopAscii}); 
                    }
                    else
                    {
                        break;
                    }
                }
                stack += character;
            }
        }
        if(stack.contains('('))
        {
            stack = stack.remove('(');
        }
        output += stack.reverse();
        return output;
    }
    private static Integer precedence(String operator)
    {
        if(operator.equals('+') || operator.equals('-'))
        {
            return 1;
        }
        else if(operator.equals('*') || operator.equals('/'))
        {
            return 2;
        }
        return 0;
    }
    
}