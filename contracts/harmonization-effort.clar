;; Superstring Harmonization Effort Contract

(define-data-var effort-counter uint u0)

(define-map harmonization-efforts uint {
    coordinator: principal,
    target-region: (string-ascii 50),
    start-time: uint,
    duration: uint,
    participants: (list 100 principal),
    status: (string-ascii 20),
    success-rate: uint
})

(define-public (create-effort (target-region (string-ascii 50)) (start-time uint) (duration uint))
    (let
        ((new-id (+ (var-get effort-counter) u1)))
        (map-set harmonization-efforts new-id {
            coordinator: tx-sender,
            target-region: target-region,
            start-time: start-time,
            duration: duration,
            participants: (list tx-sender),
            status: "planned",
            success-rate: u0
        })
        (var-set effort-counter new-id)
        (ok new-id)
    )
)

(define-public (join-effort (effort-id uint))
    (let
        ((effort (unwrap! (map-get? harmonization-efforts effort-id) (err u404))))
        (asserts! (< (len (get participants effort)) u100) (err u400))
        (ok (map-set harmonization-efforts effort-id
            (merge effort {
                participants: (unwrap! (as-max-len? (append (get participants effort) tx-sender) u100) (err u401))
            })))
    )
)

(define-public (update-effort-status (effort-id uint) (new-status (string-ascii 20)) (success-rate uint))
    (let
        ((effort (unwrap! (map-get? harmonization-efforts effort-id) (err u404))))
        (asserts! (is-eq tx-sender (get coordinator effort)) (err u403))
        (ok (map-set harmonization-efforts effort-id
            (merge effort {
                status: new-status,
                success-rate: success-rate
            })))
    )
)

(define-read-only (get-effort (effort-id uint))
    (map-get? harmonization-efforts effort-id)
)

(define-read-only (get-effort-count)
    (var-get effort-counter)
)

