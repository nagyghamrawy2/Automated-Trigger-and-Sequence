create or replace procedure seq_trig 
is

            cursor pk_cursor is
            select con.column_name , con.TABLE_NAME 
            from user_constraints  us inner join all_cons_columns con 
            on us.constraint_name = con.constraint_name 
            inner join all_tab_cols tab
            on con.table_name = tab.table_name and CON.COLUMN_NAME = tab.column_name
            where  constraint_type = 'P' 
            and us.owner = 'HR'
            and TAB.DATA_TYPE = 'NUMBER';

            cursor user_seq is 
            select * from user_sequences;
            v_max_value number(8);
            v_count number(6);
            begin
                    for pk_record in pk_cursor loop
                                        select count(*)
                                        into v_count
                                        from user_constraints  us inner join all_cons_columns con 
                                        on us.constraint_name = con.constraint_name 
                                        where  constraint_type = 'P' 
                                        and US.TABLE_NAME = pk_record.table_name;      
                                if v_count <= 1 then   
                                for user_record in user_seq loop
                                            if pk_record.table_name ||'_SEQ' = user_record.sequence_name then
                                                         EXECUTE IMMEDIATE 'DROP SEQUENCE ' ||pk_record.table_name||'_SEQ' ;
                                            end if;
                                end loop;
                              EXECUTE IMMEDIATE 'SELECT MAX( ' ||pk_record.column_name ||' ) '  || ' FROM ' ||pk_record.table_name INTO v_max_value  ;
                              
                              EXECUTE IMMEDIATE ' CREATE SEQUENCE ' ||pk_record.table_name|| '_SEQ ' ||   ' START WITH ' ||v_max_value || ' INCREMENT BY 1' ;
                              
                             EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER ' || pk_record.table_name|| '_TRG' ||
                             ' BEFORE INSERT ON ' || pk_record.table_name ||
                             ' FOR EACH ROW ' || 
                            'BEGIN ' ||
                             ' :new.'||pk_record.column_name ||' := ' ||pk_record.table_name|| '_SEQ'||'.NEXTVAL; END;'   ;                  
                              end if;
                    end loop;

end;
