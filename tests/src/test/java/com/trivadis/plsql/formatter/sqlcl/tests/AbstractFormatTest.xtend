package com.trivadis.plsql.formatter.sqlcl.tests

import java.io.File
import org.junit.Assert

abstract class AbstractFormatTest extends AbstractSqlclTest {
    
    def void process_dir(RunType runType) {
        // console output
        val expected = '''

            Formatting file 1 of 3: «tempDir.toString()»«File.separator»package_body.pkb... done.
            Formatting file 2 of 3: «tempDir.toString()»«File.separator»query.sql... done.
            Formatting file 3 of 3: «tempDir.toString()»«File.separator»syntax_error.sql... Syntax Error at line 5, column 12
            
            
               for r in /*(*/ select x.* from x join y on y.a = x.a)
                        ^^^                                          
            
            Expected: name_wo_function_call,identifier,term,factor,name,... skipped.
        '''
        val actual = run(runType, tempDir.toString(), "mext=")
        Assert.assertEquals(expected, actual)
        
        // package_body.pkb
        val expectedPackageBody = '''
            CREATE OR REPLACE PACKAGE BODY the_api.math AS
               FUNCTION to_int_table (
                  in_integers  IN  VARCHAR2,
                  in_pattern   IN  VARCHAR2 DEFAULT '[0-9]+'
               ) RETURN sys.ora_mining_number_nt
                  DETERMINISTIC
                  ACCESSIBLE BY ( PACKAGE the_api.math, PACKAGE the_api.test_math )
               IS
                  l_result  sys.ora_mining_number_nt := sys.ora_mining_number_nt();
                  l_pos     INTEGER := 1;
                  l_int     INTEGER;
               BEGIN
                  <<integer_tokens>>
                  LOOP
                     l_int               := to_number(regexp_substr(in_integers, in_pattern, 1, l_pos));
                     EXIT integer_tokens WHEN l_int IS NULL;
                     l_result.extend;
                     l_result(l_pos)     := l_int;
                     l_pos               := l_pos + 1;
                  END LOOP integer_tokens;
                  RETURN l_result;
               END to_int_table;
            END math;
            /
        '''.toString.trim
        val actualPackageBody = getFormattedContent("package_body.pkb")
        Assert.assertEquals(expectedPackageBody, actualPackageBody)

        // query.sql
        val expectedQuery = '''
            SELECT d.department_name,
                   v.employee_id,
                   v.last_name
              FROM departments d CROSS APPLY (
                      SELECT *
                        FROM employees e
                       WHERE e.department_id = d.department_id
                   ) v
             WHERE d.department_name IN (
                      'Marketing',
                      'Operations',
                      'Public Relations'
                   )
             ORDER BY d.department_name,
                      v.employee_id;
        '''.toString.trim
        val actualQuery = getFormattedContent("query.sql")
        Assert.assertEquals(expectedQuery, actualQuery)

        // syntax_error.sql
        Assert.assertEquals(getOriginalContent("syntax_error.sql"), getFormattedContent("syntax_error.sql"))

    }

    def void process_pkb_only(RunType runType) {
        // run
        val actual = run(runType, tempDir.toString(), "ext=pkb", "mext=")
        Assert.assertTrue(actual.contains("file 1 of 1"))
        
        // package_body.pkb
        val expectedPackageBody = '''
            CREATE OR REPLACE PACKAGE BODY the_api.math AS
               FUNCTION to_int_table (
                  in_integers  IN  VARCHAR2,
                  in_pattern   IN  VARCHAR2 DEFAULT '[0-9]+'
               ) RETURN sys.ora_mining_number_nt
                  DETERMINISTIC
                  ACCESSIBLE BY ( PACKAGE the_api.math, PACKAGE the_api.test_math )
               IS
                  l_result  sys.ora_mining_number_nt := sys.ora_mining_number_nt();
                  l_pos     INTEGER := 1;
                  l_int     INTEGER;
               BEGIN
                  <<integer_tokens>>
                  LOOP
                     l_int               := to_number(regexp_substr(in_integers, in_pattern, 1, l_pos));
                     EXIT integer_tokens WHEN l_int IS NULL;
                     l_result.extend;
                     l_result(l_pos)     := l_int;
                     l_pos               := l_pos + 1;
                  END LOOP integer_tokens;
                  RETURN l_result;
               END to_int_table;
            END math;
            /
        '''.toString.trim
        val actualPackageBody = getFormattedContent("package_body.pkb")
        Assert.assertEquals(expectedPackageBody, actualPackageBody)
    }
    
    def void process_with_original_arbori(RunType runType) {
        // run
        val actual = run(runType, tempDir.toString(), "arbori=" + Thread.currentThread().getContextClassLoader().getResource("original/20.2.0/custom_format.arbori").path)
        Assert.assertTrue(actual.contains("package_body.pkb"))
        Assert.assertTrue(actual.contains("query.sql"))

        // package_body.pkb
        val expectedPackageBody = '''
            CREATE OR REPLACE PACKAGE BODY the_api.math AS
               FUNCTION to_int_table (
                  in_integers  IN  VARCHAR2,
                  in_pattern   IN  VARCHAR2 DEFAULT '[0-9]+'
               ) RETURN sys.ora_mining_number_nt
                  DETERMINISTIC
                  ACCESSIBLE BY ( PACKAGE the_api.math, PACKAGE the_api.test_math )
               IS
                  l_result  sys.ora_mining_number_nt := sys.ora_mining_number_nt();
                  l_pos     INTEGER := 1;
                  l_int     INTEGER;
               BEGIN
                  << integer_tokens >> LOOP
                     l_int               := to_number(regexp_substr(
                                                     in_integers,
                                                     in_pattern,
                                                     1,
                                                     l_pos
                                        ));
                     EXIT integer_tokens WHEN l_int IS NULL;
                     l_result.extend;
                     l_result(l_pos)     := l_int;
                     l_pos               := l_pos + 1;
                  END LOOP integer_tokens;
                  RETURN l_result;
               END to_int_table;
            END math;
            /
        '''.toString.trim
        val actualPackageBody = getFormattedContent("package_body.pkb")
        Assert.assertEquals(expectedPackageBody, actualPackageBody)
 
        // query.sql
        val expectedQuery = '''
            SELECT d.department_name,
                   v.employee_id,
                   v.last_name
              FROM departments d CROSS APPLY (
               SELECT *
                 FROM employees e
                WHERE e.department_id = d.department_id
            ) v
             WHERE d.department_name IN ( 'Marketing',
                                          'Operations',
                                          'Public Relations' )
             ORDER BY d.department_name,
                      v.employee_id;
        '''.toString.trim
        val actualQuery = getFormattedContent("query.sql")
        Assert.assertEquals(expectedQuery, actualQuery)
    }

    def void process_with_default_arbori(RunType runType) {
        // run
        val actual = run(runType, tempDir.toString(), "arbori=default")
        Assert.assertTrue(actual.contains("package_body.pkb"))
        Assert.assertTrue(actual.contains("query.sql"))
        

        // package_body.pkb
        val expectedPackageBody = '''
            CREATE OR REPLACE PACKAGE BODY the_api.math AS
               FUNCTION to_int_table (
                  in_integers  IN  VARCHAR2,
                  in_pattern   IN  VARCHAR2 DEFAULT '[0-9]+'
               ) RETURN sys.ora_mining_number_nt
                  DETERMINISTIC
                  ACCESSIBLE BY ( PACKAGE the_api.math, PACKAGE the_api.test_math )
               IS
                  l_result  sys.ora_mining_number_nt := sys.ora_mining_number_nt();
                  l_pos     INTEGER := 1;
                  l_int     INTEGER;
               BEGIN
                  << integer_tokens >> LOOP
                     l_int               := to_number(regexp_substr(
                                                     in_integers,
                                                     in_pattern,
                                                     1,
                                                     l_pos
                                        ));
                     EXIT integer_tokens WHEN l_int IS NULL;
                     l_result.extend;
                     l_result(l_pos)     := l_int;
                     l_pos               := l_pos + 1;
                  END LOOP integer_tokens;
                  RETURN l_result;
               END to_int_table;
            END math;
            /
        '''.toString.trim
        val actualPackageBody = getFormattedContent("package_body.pkb")
        Assert.assertEquals(expectedPackageBody, actualPackageBody)
 
        // query.sql
        val expectedQuery = '''
            SELECT d.department_name,
                   v.employee_id,
                   v.last_name
              FROM departments d CROSS APPLY (
               SELECT *
                 FROM employees e
                WHERE e.department_id = d.department_id
            ) v
             WHERE d.department_name IN ( 'Marketing',
                                          'Operations',
                                          'Public Relations' )
             ORDER BY d.department_name,
                      v.employee_id;
        '''.toString.trim
        val actualQuery = getFormattedContent("query.sql")
        Assert.assertEquals(expectedQuery, actualQuery)
    }

    def void process_with_xml(RunType runType) {
        // run
        val actual = run(runType, tempDir.toString(), "xml=" + Thread.currentThread().getContextClassLoader().getResource("advanced_format.xml").path)
        Assert.assertTrue(actual.contains("package_body.pkb"))
        Assert.assertTrue(actual.contains("query.sql"))

        // package_body.pkb
        val expectedPackageBody = '''
            CREATE OR REPLACE PACKAGE BODY the_api.math AS
               FUNCTION to_int_table (
                  in_integers  IN  VARCHAR2
                , in_pattern   IN  VARCHAR2 DEFAULT '[0-9]+'
               ) RETURN sys.ora_mining_number_nt
                  DETERMINISTIC
                  ACCESSIBLE BY ( PACKAGE the_api.math, PACKAGE the_api.test_math )
               IS
                  l_result  sys.ora_mining_number_nt := sys.ora_mining_number_nt();
                  l_pos     INTEGER := 1;
                  l_int     INTEGER;
               BEGIN
                  <<integer_tokens>>
                  LOOP
                     l_int               := to_number(regexp_substr(in_integers, in_pattern, 1, l_pos));
                     EXIT integer_tokens WHEN l_int IS NULL;
                     l_result.extend;
                     l_result(l_pos)     := l_int;
                     l_pos               := l_pos + 1;
                  END LOOP integer_tokens;
                  RETURN l_result;
               END to_int_table;
            END math;
            /
        '''.toString.trim
        val actualPackageBody = getFormattedContent("package_body.pkb")
        Assert.assertEquals(expectedPackageBody, actualPackageBody)
 
        // query.sql
        val expectedQuery = '''
            SELECT d.department_name
                 , v.employee_id
                 , v.last_name
              FROM departments d CROSS APPLY (
                      SELECT *
                        FROM employees e
                       WHERE e.department_id = d.department_id
                   ) v
             WHERE d.department_name IN (
                      'Marketing'
                    , 'Operations'
                    , 'Public Relations'
                   )
             ORDER BY d.department_name
                    , v.employee_id;
        '''.toString.trim
        val actualQuery = getFormattedContent("query.sql")
        Assert.assertEquals(expectedQuery, actualQuery)
    }

    def void process_with_default_xml_default_arbori(RunType runType) {
        // run
        val actual = run(runType, tempDir.toString(), "xml=default", "arbori=default")
        Assert.assertTrue(actual.contains("package_body.pkb"))
        Assert.assertTrue(actual.contains("query.sql"))

        // package_body.pkb
        val expectedPackageBody = '''
            CREATE OR REPLACE PACKAGE BODY the_api.math AS
            
                FUNCTION to_int_table (
                    in_integers  IN  VARCHAR2,
                    in_pattern   IN  VARCHAR2 DEFAULT '[0-9]+'
                ) RETURN sys.ora_mining_number_nt
                    DETERMINISTIC
                    ACCESSIBLE BY ( PACKAGE the_api.math, PACKAGE the_api.test_math )
                IS
            
                    l_result  sys.ora_mining_number_nt := sys.ora_mining_number_nt();
                    l_pos     INTEGER := 1;
                    l_int     INTEGER;
                BEGIN
                    << integer_tokens >> LOOP
                        l_int := to_number(regexp_substr(in_integers, in_pattern, 1, l_pos));
                        EXIT integer_tokens WHEN l_int IS NULL;
                        l_result.extend;
                        l_result(l_pos) := l_int;
                        l_pos := l_pos + 1;
                    END LOOP integer_tokens;
            
                    RETURN l_result;
                END to_int_table;
            
            END math;
            /
        '''.toString.trim
        val actualPackageBody = getFormattedContent("package_body.pkb")
        Assert.assertEquals(expectedPackageBody, actualPackageBody)
 
        // query.sql
        val expectedQuery = '''
            SELECT
                d.department_name,
                v.employee_id,
                v.last_name
            FROM
                departments  d CROSS APPLY (
                    SELECT
                        *
                    FROM
                        employees e
                    WHERE
                        e.department_id = d.department_id
                )            v
            WHERE
                d.department_name IN ( 'Marketing', 'Operations', 'Public Relations' )
            ORDER BY
                d.department_name,
                v.employee_id;
        '''.toString.trim
        val actualQuery = getFormattedContent("query.sql")
        Assert.assertEquals(expectedQuery, actualQuery)
    }

    def void process_with_embedded_xml_default_arbori(RunType runType) {
        // run
        val actual = run(runType, tempDir.toString(), "xml=embedded", "arbori=default")
        Assert.assertTrue(actual.contains("package_body.pkb"))
        Assert.assertTrue(actual.contains("query.sql"))

        // package_body.pkb
        val expectedPackageBody = '''
            CREATE OR REPLACE PACKAGE BODY the_api.math AS
               FUNCTION to_int_table (
                  in_integers  IN  VARCHAR2,
                  in_pattern   IN  VARCHAR2 DEFAULT '[0-9]+'
               ) RETURN sys.ora_mining_number_nt
                  DETERMINISTIC
                  ACCESSIBLE BY ( PACKAGE the_api.math, PACKAGE the_api.test_math )
               IS
                  l_result  sys.ora_mining_number_nt := sys.ora_mining_number_nt();
                  l_pos     INTEGER := 1;
                  l_int     INTEGER;
               BEGIN
                  << integer_tokens >> LOOP
                     l_int               := to_number(regexp_substr(
                                                     in_integers,
                                                     in_pattern,
                                                     1,
                                                     l_pos
                                        ));
                     EXIT integer_tokens WHEN l_int IS NULL;
                     l_result.extend;
                     l_result(l_pos)     := l_int;
                     l_pos               := l_pos + 1;
                  END LOOP integer_tokens;
                  RETURN l_result;
               END to_int_table;
            END math;
            /
        '''.toString.trim
        val actualPackageBody = getFormattedContent("package_body.pkb")
        Assert.assertEquals(expectedPackageBody, actualPackageBody)
 
        // query.sql
        val expectedQuery = '''
            SELECT d.department_name,
                   v.employee_id,
                   v.last_name
              FROM departments d CROSS APPLY (
               SELECT *
                 FROM employees e
                WHERE e.department_id = d.department_id
            ) v
             WHERE d.department_name IN ( 'Marketing',
                                          'Operations',
                                          'Public Relations' )
             ORDER BY d.department_name,
                      v.employee_id;
        '''.toString.trim
        val actualQuery = getFormattedContent("query.sql")
        Assert.assertEquals(expectedQuery, actualQuery)
    }
    
    def process_markdown_only(RunType runType) {
        // run
        val actualConsole = run(runType, tempDir.toString(), "ext=")
        Assert.assertTrue (actualConsole.contains('''Formatting file 1 of 1: «tempDir.toString()»«File.separator»markdown.md... done.'''))
        
        // markdown.md
        val actualMarkdown = getFormattedContent("markdown.md").trim
        val expectedMarkdown = '''
            # Titel
            
            ## Introduction
            
            This is a Markdown file with some `code blocks`. 
            
            ## Package Body
            
            Here's the content of package_body.pkb
            
            ```sql
            CREATE OR REPLACE PACKAGE BODY the_api.math AS
               FUNCTION to_int_table (
                  in_integers  IN  VARCHAR2,
                  in_pattern   IN  VARCHAR2 DEFAULT '[0-9]+'
               ) RETURN sys.ora_mining_number_nt
                  DETERMINISTIC
                  ACCESSIBLE BY ( PACKAGE the_api.math, PACKAGE the_api.test_math )
               IS
                  l_result  sys.ora_mining_number_nt := sys.ora_mining_number_nt();
                  l_pos     INTEGER := 1;
                  l_int     INTEGER;
               BEGIN
                  <<integer_tokens>>
                  LOOP
                     l_int               := to_number(regexp_substr(in_integers, in_pattern, 1, l_pos));
                     EXIT integer_tokens WHEN l_int IS NULL;
                     l_result.extend;
                     l_result(l_pos)     := l_int;
                     l_pos               := l_pos + 1;
                  END LOOP integer_tokens;
                  RETURN l_result;
               END to_int_table;
            END math;
            /
            ```
            
            ## Syntax Error
            
            Here's the content of syntax_error.sql
            
            ```  sql
            declare
                l_var1  integer;
                l_var2  varchar2(20);
            begin
                for r in /*(*/ select x.* from x join y on y.a = x.a)
                loop
                  p(r.a, r.b, r.c);
                end loop;
            end;
            /
            ```
            
            ## Query (to be ignored)
            
            Here's the content of query.sql, but the code block must not be formatted:
            
            ```
            Select d.department_name,v.  employee_id 
            ,v 
            . last_name frOm departments d CROSS APPLY(select*from employees e
              wHERE e.department_id=d.department_id) v WHeRE 
            d.department_name in ('Marketing'
            ,'Operations',
            'Public Relations') Order By d.
            department_name,v.employee_id;
            ```
            
            ## Query (to be formatted)
            
            Here's the content of query.sql:
            
            ``` sql
            SELECT d.department_name,
                   v.employee_id,
                   v.last_name
              FROM departments d CROSS APPLY (
                      SELECT *
                        FROM employees e
                       WHERE e.department_id = d.department_id
                   ) v
             WHERE d.department_name IN (
                      'Marketing',
                      'Operations',
                      'Public Relations'
                   )
             ORDER BY d.department_name,
                      v.employee_id;
            ```
            
            ## JavaScript code
            
            Here's another code wich must not be formatted
            
            ``` js
            var foo = function (bar) {
              return bar++;
            };
            ```
        '''.toString.trim
         Assert.assertEquals(expectedMarkdown, actualMarkdown)
    }

}
