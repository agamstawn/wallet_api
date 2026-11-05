alice = User.find_or_create_by!(email: "alice@example.com") { |u| u.name = "Alice"; u.password = "password123" }
bob   = User.find_or_create_by!(email: "bob@example.com")   { |u| u.name = "Bob";   u.password = "password123" }
team  = Team.find_or_create_by!(name: "Engineering")
stock = Stock.find_or_create_by!(symbol: "RELIANCE") { |s| s.name = "Reliance Industries" }

alice.wallet.deposit!(1000) if alice.wallet.balance.zero?

puts "Alice wallet=#{alice.wallet.id} Bob wallet=#{bob.wallet.id} " \
     "Team wallet=#{team.wallet.id} Stock wallet=#{stock.wallet.id}"
