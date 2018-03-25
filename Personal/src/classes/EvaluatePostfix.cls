public class EvaluatePostfix 
{
    public static void evaluateExpression(String expression)
    {
        List<String> stack = new List<String>();
        Integer operand;
        Integer i=0;
        while(!String.isEmpty(expression) && i<expression.length())
        {
            Integer x = expression.charAt(i);
            String character = String.fromCharArray(new List<Integer>{x});
            if(character.isNumeric())
            {
                stack.add(character);
            }
            else
            {
                Integer operand1 = Integer.valueOf(stack.get(stack.size()-1));
                Integer operand2 = Integer.valueOf(stack.get(stack.size()-2));
                stack.remove(stack.size()-1);
                stack.remove(stack.size()-1);
                stack.add(evaluate(operand2,operand1,character));
            }
            i++;
        }
        system.debug('stack--->'+stack);
    }
    public static String  evaluate(Integer operand1,Integer operand2,String character)
    {
        if(character == '+')
        {
            return String.valueof(operand1+operand2);
        }
        else if(character == '-')
        {
            return String.valueof(operand1-operand2);
        }
        else if(character == '*')
        {
            return String.valueof(operand1*operand2);
        }
        else if(character == '/')
        {
             return String.valueof(operand1/operand2);
        }
        return '0';
    }

}