;; Universe Stability Index Contract

(define-map stability-indices uint {
    region: (string-ascii 50),
    index: uint,
    last-updated: uint,
    contributor: principal
})

(define-data-var region-counter uint u0)

(define-public (update-stability-index (region (string-ascii 50)) (new-index uint))
    (let
        ((region-id (default-to (+ (var-get region-counter) u1) (get-region-id region))))
        (map-set stability-indices region-id {
            region: region,
            index: new-index,
            last-updated: block-height,
            contributor: tx-sender
        })
        (if (is-none (get-region-id region))
            (var-set region-counter region-id)
            true
        )
        (ok region-id)
    )
)

(define-read-only (get-stability-index (region-id uint))
    (map-get? stability-indices region-id)
)

(define-read-only (get-region-id (region (string-ascii 50)))
    (fold (lambda (id result)
        (if (and (is-none result) (is-eq (get region (unwrap! (map-get? stability-indices id) none)) region))
            (some id)
            result
        )
    ) none (range u1 (+ (var-get region-counter) u1)))
)

(define-read-only (get-region-count)
    (var-get region-counter)
)

