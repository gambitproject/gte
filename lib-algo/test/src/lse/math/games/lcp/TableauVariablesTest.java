package lse.math.games.lcp;

import org.junit.Test;
import static org.junit.Assert.*;

public class TableauVariablesTest {
	@Test
     public void testVariableAssignments()
     {
         int n = 4;
         TableauVariables vars = new TableauVariables(n);
         
         for (int i = 0; i <= n; ++i) {
             int var = vars.z(i);
             assertEquals(i, var);
             assertEquals(i, vars.col(var));
             assertEquals(var, vars.colVar(i));
             assertFalse(String.format("z%d should NOT be basic", i), vars.isBasic(var));            
         }
         for (int i = 1; i <= n; ++i) {
             int var = vars.w(i);
             assertEquals(i + n, var);
             assertEquals(i - 1, vars.row(var));
             assertEquals(var, vars.rowVar(i - 1));
             assertTrue(String.format("w%d should be basic", i), vars.isBasic(var));
         }
     }      

     @Test
     public void testSwap()
     {
         int n = 4;
         TableauVariables vars = new TableauVariables(n);

         int leaveVar = vars.w(1);
         int enterVar = vars.z(0);

         int row = vars.row(leaveVar);
         int col = vars.col(enterVar);
           
         vars.swap(vars.z(0), vars.w(1), row, col);

         assertEquals(col, vars.col(leaveVar));
         assertEquals(row, vars.row(enterVar));

         assertEquals(leaveVar, vars.colVar(col));
         assertEquals(enterVar, vars.rowVar(row));
     }

     @Test
     public void testComplement()
     {
         TableauVariables vars = new TableauVariables(4);

         for (int i = 1; i <= vars.size(); ++i) {
             int var = vars.complement(vars.z(i));
             assertEquals(vars.w(i), var);
         }

         try {
             vars.complement(vars.z(0));
             assertFalse("Should not be able to get complement of z0", true);
         }
         catch (Exception ex) { }
     }
}
