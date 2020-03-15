(require :jaxon_jvrc-interface "package://hrpsys_choreonoid_tutorials/euslisp/jaxon_jvrc-interface.l")

(require :clicked-pick-util "package://aizuspider_description/clicked-pick-util.l")

(defun initialize-clicked-pick ()
  (jaxon_jvrc-init)
  (send *ri* :start-auto-balancer)
  (setq *robot* (jaxon_jvrc))
  ;;; fixed variables
  (setq *grasp-offset*   (float-vector -15 0 0))

  (setq *pre-manipulation-pose* (list :reset-manip-pose))
  (setq *hold-object-pose*      (list :reset-manip-pose))

  (setq *fixed-frame-id* "BODY")
  (send *ri* :go-pos 5. -1.4 0)
  ;;(setq *fixed-frame-id* "JAXON_JVRC/WAIST")
  )

(warn "
(initialize-clicked-pick)
")

(defun pre-manipulation-pose()
  (send* *robot* *pre-manipulation-pose*)
  (send *robot* :reset-pose)
  (send *ri* :wait-interpolation)
  )

(defun ik-for-target-pos-jaxon (target-pos &key (arm :rarm) (offset) (world nil))
  (unless offset (setq offset (float-vector 0 0 0)))
  (when world
    (let ((cur-base
           (send *tfl* :lookup-transform "map" "base_footprint" (ros::time 0))))
      (setq target-pos
            (send
             (send cur-base :transformation (make-coords :pos target-pos))
             :worldpos))
      ))
  (send *robot* :reset-coords)
  (send* *robot* *pre-manipulation-pose*)
  (send *ri* :move-gripper :rarm 0)
  (send *ri* :wait-interpolation)
  (send *robot* arm :inverse-kinematics
        (make-coords :pos target-pos)
        :rotation-axis nil)
  (send *ri* :angle-vector (send *robot* :angle-vector) 3000 :rarm-controller 0)
  (send *ri* :move-gripper :rarm 0)
  (send *ri* :wait-interpolation)
  )

(defun click-and-pick-it-jaxon (&key (reset-pose nil) (arm :rarm) (move-time 1400))
  (when reset-pose
    ;;(send *ri* :stop-grasp)
    (send *robot* :reset-pose)
    (send *ri* :angle-vector
          (send* *robot* *pre-manipulation-pose*) move-time)
    (send *ri* :wait-interpolation)
    )

  ;; get world position which was clicked at the image
  (setq pos (get-clicked-position))

  (when (y-or-n-p (format nil "Can I pick it? ~A" pos))
    ;; inverse kinematics
    (ik-for-target-pos-jaxon pos :arm arm :world nil)
    (send *ri* :move-gripper :rarm 0)
    (send *ri* :wait-interpolation)

    ;; grasp
    (send *ri* :move-gripper :rarm 0.75)
    (send *ri* :wait-interpolation)

    ;; pick-up
    (when (send *robot* arm :move-end-pos #f(0 0 100) :world)
      (send *ri* :angle-vector (send *robot* :angle-vector) move-time)
      (warn "lifting up..")
      (send *ri* :wait-interpolation)
      )

    ;; hold pose
    ;;(send* *robot* *hold-object-pose*)
    ;;(send *ri* :angle-vector (send *robot* :angle-vector) move-time)
    ;;(send *ri* :wait-interpolation)
    (return-from click-and-pick-it-jaxon t)
    )
  nil
  )
