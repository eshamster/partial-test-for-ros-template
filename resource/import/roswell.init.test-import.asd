(DEFPACKAGE :ROSWELL.INIT.TEST-IMPORT
  (:USE :CL))
(IN-PACKAGE :ROSWELL.INIT.TEST-IMPORT)
(DEFVAR *PARAMS*
  '(:FILES
    ((:NAME "dir/file3" :METHOD "copy" :REWRITE "dir/{{ name }}.txt")
     (:NAME "file2" :METHOD "copy" :CHMOD "0600")
     (:NAME "file1" :METHOD "djula"))))
(DEFUN TEST-IMPORT (_ &REST R)
  (ASDF/OPERATE:LOAD-SYSTEM :ROSWELL.UTIL.TEMPLATE :VERBOSE NIL)
  (FUNCALL (READ-FROM-STRING "roswell.util.template:template-apply") _ R
           *PARAMS*))
