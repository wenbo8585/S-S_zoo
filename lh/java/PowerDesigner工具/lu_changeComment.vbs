'******************************************************************************
'* File:     comment2code.vbs
'* Purpose: ��PowerDesigner��PDMͼ�δ�������ʾ�����е�����ע��
'* Title:    ���ֶε�comment��ֵ���ֶε�code��
'* Category: ������ģ�ͣ����б��ű���Ctrl+Shift+X��
'* Copyright:foxzz@163.com,2006/07/25 .
'* Author:   foxzz
'* Created:
'* Modified:
'* Version: 1.0
'* Comment: ��������ģ���е����б����ֶε�comment��ֵ���ֶε�code�С�
'            �ڽ�code�û�Ϊcomment�����У���Ҫ���ǵ�����
'            1��code����Ψһ����comment�п��ܲ�Ψһ��
'               ����취������ֶε�comment�ظ������ֶε�code=comment+1��2��3...
'            2��commentֵ�п���Ϊ�գ���������¶��ֶε�code������
'               ���oracle���ݿ�,��comment on column �ֶ����� is '';��ӵ�C:\pdcomment.txt�ļ��С�
'               �ڲ���comment��Ϻ󣬱��������ݿ���ִ��      
'******************************************************************************
 
Option Explicit
ValidationMode = True
InteractiveMode = im_Batch
 
Dim system, file
Set system = CreateObject("Scripting.FileSystemObject")
Dim ForReading, ForWriting, ForAppending   '���ļ�ѡ��
ForReading   = 1 ' ֻ��
ForWriting   = 2 ' ��д
ForAppending = 8 ' ��д��׷��
'���ı��ļ�
Set file = system.OpenTextFile("C:\pdcomment.txt", ForWriting, true)
 
 
'�жϵ�ǰmodel�Ƿ���������ģ��
Dim mdl
Set mdl = ActiveModel
If (mdl Is Nothing) Then
   MsgBox "���������ģ��"
ElseIf Not mdl.IsKindOf(PdPDM.cls_Model) Then
   MsgBox "��ǰģ�Ͳ�����������ģ��"
Else
   ProcessFolder mdl,file
End If
file.Close
 
 
'******************************************************************************
Private sub ProcessFolder(folder,file)
 
Dim i,j,k
i=0:j=0:k=0
 
'�����飬��¼�ֶ��ﲻ�ظ���comment
Dim ColumnComment()
Dim ColumnCommentNumber()
ReDim Preserve ColumnComment(i)
ReDim Preserve ColumnCommentNumber(i)
 
Dim tbl   '��ǰ��
Dim col   '��ǰ�ֶ�
dim curComment '��ǰ�ֶ�comment
 
'����ģ���еı�
for each tbl in folder.tables
    if not tbl.isShortcut then
       if len(trim(tbl.comment))<>0 then
          '������������ʾtable��comment
          'tbl.name = tbl.name+"("+trim(tbl.comment)+")"
       end if 
 
       '������е���
       for each col in tbl.columns
           k = 0
           curComment = trim(col.comment)
           if len(curComment)<>0 then
              '���������comment����
              for j = 0 to i
                  if ColumnComment(j) = curComment then
                     '����ҵ���ͬ��comment,����ؼ�������1
                     ColumnCommentNumber(j) = ColumnCommentNumber(j) + 1
                     k = j
                  end if
              Next
              '���û����ͬ��comment,��k=0,��ʱColumnCommentNumber(0)ҲΪ0
              '����ColumnCommentNumber(k)��Ϊ0
              if ColumnCommentNumber(k) <> 0 then
                 col.name = curComment & cstr(ColumnCommentNumber(k))
              else
                 col.name = curComment
                 'ColumnComment(0)��ColumnCommentNumber(0)��ԶΪ��
                 '�������comment��¼��ӵ�������
                 i = i + 1
                 ReDim Preserve ColumnComment(i)
                 ReDim Preserve ColumnCommentNumber(i)
                 ColumnComment(i) = curComment
                 ColumnCommentNumber(i) = 0
              end if
           else
              'д���ļ���
              file.WriteLine "comment on column "+ tbl.name+"."+col.name+" is '';"         
           end if
       next
    end if
    '���ڲ�ͬ���code������ͬ,��˴�ʱ���³�ʼ����
    '��ΪColumnComment(0)��ColumnCommentNumber(0)Ϊ�գ����Ա���
    ReDim Preserve ColumnComment(0)
    ReDim Preserve ColumnCommentNumber(0)
    i=0:j=0:k=0
 
next
 
Dim view '��ǰ��ͼ
for each view in folder.Views
    if not view.isShortcut then
       '������������ʾview��comment
       'view.name = view.comment
    end if
next
 
'����Ŀ¼���еݹ�
Dim subpackage 'folder
For Each subpackage In folder.Packages
    if not subpackage.IsShortcut then
       ProcessFolder subpackage , file
    end if
Next
 
end sub
