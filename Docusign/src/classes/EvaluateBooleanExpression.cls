public class EvaluateBooleanExpression 
{
    public static Boolean evaluateInfixExpression(String infixExpression)
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
            if(character != '&' && character != '|' && character != '(' && character != ')')
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
        Boolean value = evaluatePostfixExpression(output);
        return value;
    }
    
    private static Integer precedence(String operator)
    {
        if(operator.equals('&') )
        {
            return 2;
        }
        else if(operator.equals('|') )
        {
            return 1;
        }
        return 0;
    }
    private static Boolean evaluatePostfixExpression(String expression)
    {
        List<String> stack = new List<String>();
        Integer operand;
        Integer i=0;
        while(!String.isEmpty(expression) && i<expression.length())
        {
            Integer x = expression.charAt(i);
            String character = String.fromCharArray(new List<Integer>{x});
            if(character != '&' && character != '|')
            {
                stack.add(character);
            }
            else
            {
                String operand1 = stack.get(stack.size()-1);
                String operand2 = stack.get(stack.size()-2);
                stack.remove(stack.size()-1);
                stack.remove(stack.size()-1);
                stack.add(evaluate(operand2,operand1,character));
            }
            i++;
        }
        if(stack[0] == 'T') 
        {
            return true;
        }
        return false;
    }
    private static String  evaluate(String operandParam1,String operandParam2,String character)
    {
        String output = '';
        Boolean operand1, operand2;
        if(operandParam1 == 'T')
        {
            operand1 = true;
        }
        else
        {
            operand1 = false;
        }
        if(operandParam2 == 'T')
        {
            operand2 = true;
        }
        else
        {
            operand2 = false;
        }
        if(character == '&')
        {
            output =  String.valueof(operand1 && operand2);
        }
        else if(character == '|')
        {
            output =  String.valueof(operand1 || operand2);
        }
        if(output == 'true')
            return 'T';
        else
            return 'F';
        return 'F';
    }
}