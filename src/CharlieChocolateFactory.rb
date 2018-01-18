require 'bitcoin'
require 'openassets'

include OpenAssets::Util

Bitcoin.network = :regtest

api = OpenAssets::Api.new({
       network:             'regtest',
       provider:           'bitcoind',
       cache:              ':memory:',
       dust_limit:                600,
       default_fees:            10000,
       min_confirmation:            0,
       max_confirmation:      9999999,
       rpc: {
         user:             'username',
         password:         'password',
         schema:               'http',
         port:                   8332,
         host:            'localhost',
         timeout:                  60,
         open_timeout:             60 }
   })

# Issuer (Charlie)
charlie_key = Bitcoin::Key.generate
charlie_bt_addr = charlie_key.addr
charlie_oa_addr = OpenAssets::Util.address_to_oa_address(charlie_bt_addr)

puts "Charlie's BTC address is " + charlie_bt_addr
puts "Charlie's OA address is " + charlie_oa_addr

api.provider.importprivkey(charlie_key.to_base58, "Charlie", false)

# Mine blocks
mine_times = 200
api.provider.generatetoaddress(mine_times, charlie_key.addr)

# puts "List unspents:"
# puts api.provider.list_unspent([charlie_bt_addr])

# Our lucky winners (chocolate buyers)
alice_key = Bitcoin::Key.generate
bob_key = Bitcoin::Key.generate

# Charlie issues assets
number_of_golden_ticket = 10

puts "Charlie is issuing " + number_of_golden_ticket.to_s + " exclusive Golden Tickets."
api.issue_asset(charlie_oa_addr, number_of_golden_ticket, "Charlie's Golden Ticket",
                charlie_oa_addr, nil, 'broadcast', number_of_golden_ticket)

# Check balance
balances = api.get_balance(charlie_oa_addr)
puts balances

balances.each_with_index { |balance, index|
  assets = balance['assets']
  assets.each_with_index { |a, i|
    puts "Charlie now has " + a['amount'].to_s + " assets with ID: " + a['asset_id'].to_s
  }
}