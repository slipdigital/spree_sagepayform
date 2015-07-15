module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    module Integrations #:nodoc:
      module SagePayFormV3
        module Encryption
          def sage_encrypt(plaintext, key)
            SagepayProtocol3::Encryption.encrypt(key, plaintext).upcase
          end

          def sage_decrypt(ciphertext, key)
            SagepayProtocol3::Encryption.decrypt(key, ciphertext)
          end

          def sage_encrypt_salt(min, max)
            length = rand(max - min + 1) + min
            SecureRandom.base64(length + 4)[0, length]
          end

          private

          def sage_encrypt_xor(data, key)
            raise 'No key provided' if key.blank?

            key *= (data.bytesize.to_f / key.bytesize.to_f).ceil
            key = key[0, data.bytesize]

            data.bytes.zip(key.bytes).map { |b1, b2| (b1 ^ b2).chr }.join
          end
        end
      end
    end
  end
end
