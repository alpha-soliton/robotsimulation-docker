(require :jvrc-standup "package://hrpsys_choreonoid_tutorials/euslisp/action_and_perception/jvrc-statenet.l")
(load "package://hrpsys_choreonoid_tutorials/euslisp/jaxon_jvrc-interface.l")

(jaxon_jvrc-init)

;; you should comment out for walking
;;(send *ri* :stop-impedance :arms)
;;(send *robot* :reset-pose)
;;(send *robot* :fix-leg-to-coords (make-coords))
;;(send *robot* :move-centroid-on-foot :both (list :rleg :lleg))
;;(send *ri* :angle-vector (send *robot* :angle-vector) 1000)
;;(send *ri* :stop-st)
;;(send *ri* :stop-auto-balancer)
;;


(defun my-function ()
  (send *ri* :start-auto-balancer)

  (send *ri* :go-pos -0.1 0 0)

  (setq *robot* (jaxon_jvrc))
  (send *robot* :fix-leg-to-coords (make-coords))
  (send *robot* :larm :inverse-kinematics (make-coords :pos #f(0 440 1160) :rpy (list 0 0 pi/2)) :rotation-axis :z)
  (send *robot* :move-centroid-on-foot :both (list :rleg :lleg :rarm :larm))
  (send *ri* :angle-vector (send *robot* :angle-vector) 4000)
  (send *ri* :wait-interpolation)

  (send *robot* :larm :inverse-kinematics (make-coords :pos #f(0 700 1160) :rpy (list 0 0 pi/2)) :rotation-axis :z)
  (send *robot* :move-centroid-on-foot :both (list :rleg :lleg :rarm :larm))
  (send *ri* :angle-vector (send *robot* :angle-vector) 1000)
  (send *ri* :wait-interpolation)
  (send *ri* :move-gripper :larm 0.75)

  (send *robot* :larm :inverse-kinematics (make-coords :pos #f(0 700 1100) :rpy (list 0 0 pi/2)) :rotation-axis :z)
  (send *robot* :move-centroid-on-foot :both (list :rleg :lleg :rarm :larm))
  (send *ri* :angle-vector (send *robot* :angle-vector) 1000)

  (send *ri* :go-pos 0 -2. 0)
  (send *ri* :move-gripper :larm 0)
  (send *ri* :go-pos 1 2. 0)

  (send *robot* :reset-pose)
  (send *ri* :go-pos 3.7 -0.9 0)

  (send *robot* :lleg :crotch-p :joint-angle -60)
  (send *robot* :rleg :crotch-p :joint-angle -60)
  (send *robot* :lleg :knee-p :joint-angle 120)
  (send *robot* :rleg :knee-p :joint-angle 120)
  (send *robot* :lleg :ankle-p :joint-angle -60)
  (send *robot* :rleg :ankle-p :joint-angle -60)
  (send *robot* :rarm :shoulder-p :joint-angle -20)
  (send *robot* :larm :shoulder-p :joint-angle -20)
  (send *robot* :rarm :elbow-p :joint-angle 0)
  (send *robot* :larm :elbow-p :joint-angle 0)
  (send-pose :real t :base-time 3000) ;; send pose to real robot

  (send *ri* :go-pos 1 0 0)
)


(defun your-function ()
  ;; robot is moved to face-up posture
  (reset-position :coords (make-coords
                           :pos (float-vector 0 0 300) ;; (x y z) [mm] position of waist
                           :rpy (list 0 -pi/2 0) ;; (yaw pitch roll) [rad] rotation of waist
                           ))

  (send *robot* :reset-pose)
  (objects (list *robot*)) ;; visualize robot
  ;; the robot in the simulation moves to the same pose as *robot*. it takes base-time [ms].
  (send-pose :real t :base-time 2000)

  ;; (face-up-to-face-down-action :real t)
  ;; this programs is in "package://hrpsys_choreonoid_tutorials/euslisp/action_and_perception/jvrc-standup.l")
  (setq real t
        base-time 2500)
  ;; pose 0
  (send *robot* :init-pose)
  (send-pose :real real :base-time base-time)

  ;; pose1
  (send *robot* :rarm :collar-y   :joint-angle 80)
  (send *robot* :larm :shoulder-p :joint-angle -90)
  (send *robot* :lleg :crotch-p   :joint-angle -70)
  (send *robot* :lleg :crotch-y   :joint-angle -15)
  (send-pose :real real :base-time base-time) ;; send pose to real robot

  ;; pose 2
  (send *robot* :rleg :knee-p   :joint-angle 90)
  (send *robot* :rleg :crotch-y :joint-angle -49)
  (send *robot* :lleg :knee-p   :joint-angle 90)
  (send-pose :real real :base-time base-time) ;; send pose to real robot

  ;; pose 3
  (send *robot* :rleg :crotch-y :joint-angle 49)
  (send-pose :real real :base-time base-time)

  ;; pose 4
  (send *robot* :larm :shoulder-p :joint-angle -90)
  (send *robot* :rarm :collar-y   :joint-angle 0)
  (send *robot* :lleg :knee-p     :joint-angle 0)
  (send *robot* :rarm :shoulder-p :joint-angle 45)
  (send-pose :real real :base-time base-time)  ;; send pose to real robot

  ;; pose 5
  (send *robot* :init-pose) ;; return to initial pose, the robot is expected to be face-down...
  (send-pose :real real :base-time base-time)
  )
