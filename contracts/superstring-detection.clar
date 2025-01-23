;; Superstring Detection Node Contract

(define-data-var node-counter uint u0)

(define-map detection-nodes uint {
    operator: principal,
    location: (string-ascii 50),
    sensitivity: uint,
    last-detection: uint,
    total-detections: uint,
    status: (string-ascii 20)
})

(define-public (register-node (location (string-ascii 50)) (sensitivity uint))
    (let
        ((new-id (+ (var-get node-counter) u1)))
        (map-set detection-nodes new-id {
            operator: tx-sender,
            location: location,
            sensitivity: sensitivity,
            last-detection: u0,
            total-detections: u0,
            status: "active"
        })
        (var-set node-counter new-id)
        (ok new-id)
    )
)

(define-public (report-detection (node-id uint))
    (let
        ((node (unwrap! (map-get? detection-nodes node-id) (err u404))))
        (asserts! (is-eq tx-sender (get operator node)) (err u403))
        (ok (map-set detection-nodes node-id
            (merge node {
                last-detection: block-height,
                total-detections: (+ (get total-detections node) u1)
            })))
    )
)

(define-public (update-node-status (node-id uint) (new-status (string-ascii 20)))
    (let
        ((node (unwrap! (map-get? detection-nodes node-id) (err u404))))
        (asserts! (is-eq tx-sender (get operator node)) (err u403))
        (ok (map-set detection-nodes node-id
            (merge node { status: new-status })))
    )
)

(define-read-only (get-node (node-id uint))
    (map-get? detection-nodes node-id)
)

(define-read-only (get-node-count)
    (var-get node-counter)
)

