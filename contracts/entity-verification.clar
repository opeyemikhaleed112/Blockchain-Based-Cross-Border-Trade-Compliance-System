;; entity-verification.clar
;; This contract validates international businesses

(define-data-var admin principal tx-sender)

;; Entity status: 0 = unverified, 1 = verified, 2 = suspended
(define-map entities principal
  {
    status: uint,
    name: (string-utf8 100),
    country: (string-utf8 50),
    registration-number: (string-utf8 50),
    verification-date: uint
  }
)

(define-read-only (get-entity (entity-id principal))
  (default-to
    {
      status: u0,
      name: u"",
      country: u"",
      registration-number: u"",
      verification-date: u0
    }
    (map-get? entities entity-id)
  )
)

(define-public (register-entity (name (string-utf8 100)) (country (string-utf8 50)) (registration-number (string-utf8 50)))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (map-set entities tx-sender
      {
        status: u0,
        name: name,
        country: country,
        registration-number: registration-number,
        verification-date: u0
      }
    ))
  )
)

(define-public (verify-entity (entity-id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? entities entity-id)) (err u404))
    (ok (map-set entities entity-id
      (merge (unwrap-panic (map-get? entities entity-id))
        {
          status: u1,
          verification-date: block-height
        }
      )
    ))
  )
)

(define-public (suspend-entity (entity-id principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? entities entity-id)) (err u404))
    (ok (map-set entities entity-id
      (merge (unwrap-panic (map-get? entities entity-id))
        {
          status: u2
        }
      )
    ))
  )
)

(define-read-only (is-verified (entity-id principal))
  (is-eq (get status (get-entity entity-id)) u1)
)

(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)
