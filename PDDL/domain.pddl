(define (domain airline)
    (:requirements :typing :fluents)
    (:types city group plane)

    (:predicates
                ; Planes
                (plane-at ?p -plane ?x -city)

                ; People groups
                (group-at ?g -group ?x -city)
                (group-want ?g -group ?y -city)
                (group-in-plane ?g -group ?p -plane)
                (group-just-unboarded ?g -group ?p -plane)
                (deadline-reached ?p - plane) ; This plane can't fly anymore
    )

    (:functions
                (city-distance ?x ?y -city)  ; Distance between cities
                
                (group-number ?g -group)  ; Number of people in group
                (group-time ?g -group) ; Group stopwatch
                (group-flights-count ?g -group) ; How many times group ?g was unboarded

                (plane-seats ?p -plane)  ; Number of seats in place
                (plane-onboard ?p -plane) ; Number of group in plane
                (plane-time ?p -plane) ; Plane stopwatch

                (ticket-cost ?x ?y -city) ; Cost of ticket from city x to y

                ; Global
                (deadline)
                (happy-people)
                (tot-people)
    )

    (:action fly :parameters (?p -plane ?x ?y -city)  ; Fly plane p from city x to city y
                 :precondition (and (plane-at ?p ?x)
                                    (not (deadline-reached ?p))
                               )
                 :effect (and (plane-at ?p ?y)
                              (not (plane-at ?p ?x))
                              (increase (plane-time ?p) (city-distance ?x ?y))
                              (when (>= (plane-time ?p) (deadline)) (deadline-reached ?p))
                              (increase (revenue) (* (plane-onboard ?p) (ticket-cost ?x ?y)))
                         )
    )

    (:action board :parameters(?g -group ?p -plane ?x -city)  ; Board group g at plane p in city x
                   :precondition (and (not (deadline-reached ?p))
                                      (group-at ?g ?x)
                                      (not (group-want ?g ?x))
                                      (not (group-just-unboarded ?g ?p))
                                      (< (group-flights-count ?g) 10)
                                      (plane-at ?p ?x)
                                      (>= (-(plane-seats ?p) (plane-onboard ?p)) (group-number ?g))
                                )
                   :effect (and (increase (plane-onboard ?p) (group-number ?g))
                                (not (group-at ?g ?x))
                                (group-in-plane ?g ?p)
                                (when (> (group-time ?g) (plane-time ?p))
                                      (assign (plane-time ?p) (group-time ?g))
                                )
                                (increase (plane-time ?p) 1)
                                (increase (group-time ?g) 1)
                            )
    )

    (:action unboard :parameters(?g -group ?p -plane ?x -city)  ; Unboard group g from plane p in city x
                   :precondition (and (group-in-plane ?g ?p)
                                      (plane-at ?p ?x)
                                 )
                   :effect (and (decrease (plane-onboard ?p) (group-number ?g))
                                (group-at ?g ?x)
                                (group-just-unboarded ?g ?p)
                                (not (group-in-plane ?g ?p))
                                (when (group-want ?g ?x)
                                    (increase (happy-people) (group-number ?g)))
                                (increase (group-flights-count ?g) 1)
                                (assign (group-time ?g) (plane-time ?p))
                                (increase (plane-time ?p) 1)
                                (increase (group-time ?g) 1)
                            )
    )    
)