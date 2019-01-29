--查询是否有死锁的对象
select * from v$locked_object

--查询死锁原因 select * 查看更多的信息
select C.sid,C.serial#,B.object_name,C.username,C.machine,C.terminal,C.program
from v$locked_object A,all_objects B,v$session C
where A.session_id = C.sid and A.object_id = B.object_id;

--杀掉死锁会话
select b.sid,b.machine,c.object_name,a.oracle_username, a.locked_mode,b.osuser,'alter system kill session '''||b.sid||','||b.serial#||''';'
from v$locked_object a,v$session b,all_objects c
where a.session_id=b.sid and a.object_id=c.object_id;

--防止数据库死锁注意事项
  --严禁使用for update进行数据更新，for update，极易导致多人使用数据库时锁库
    --如果非得使用for update，请了解清楚如下sql以后选择性低使用for update
    --select * from t for update 会等待行锁释放之后，返回查询结果。
    --select * from t for update nowait 不等待行锁释放，提示锁冲突，不返回结果
    --select * from t for update wait 5 等待5秒，若行锁仍未释放，则提示锁冲突，不返回结果
    --select * from t for update skip locked 查询返回查询结果，但忽略有行锁的记录 
  --需要更新数据时
    --写好sql语句直接更新，update t set xxx=yyy;commit;更新数据之后立刻提交
	--使用rowid查询以后修改数据，select t.*,t.rowid from t，查询以后在结果中可直接修改数据，修改以后立刻提交
	
--总之，使用原则，如非必要不锁定数据库，如确需锁定数据库，修改数据有应马上提交	
改了数据之后要记录备份