public class EvaluateBooleanExpression3 {public static void evaluateExpression(String expression)
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
        system.debug('stack--->'+stack);
    }
    public static String  evaluate(String operandParam1,String operandParam2,String character)
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