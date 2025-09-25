# frozen_string_literal: true

namespace :import do
  desc "Import data from PostgreSQL friale database"
  task friale_db: :environment do
    puts "Starting Friale DB import..."

    begin
      importer = Importers::FrialeDbImporter.new
      importer.generate_all!

      puts "\n📈 Current Database Totals:"
      puts "  Users: #{User.count}"
      puts "  Locations: #{Location.count}"
      puts "  Firm Accounts: #{FirmAccount.count}"
      puts "  Funds: #{Fund.count}"
      puts "  Companies: #{Company.count}"
      puts "  Company Locations: #{CompanyLocation.count}"
      puts "  Company Notes: #{CompanyNote.count}"
      puts "  Investor Accounts: #{InvestorAccount.count}"
      puts "  Positions: #{Position.count}"
      puts "  Assets: #{Asset.count}"
      puts "  Marks: #{Mark.count}"
      puts "  Bank Accounts: #{BankAccount.count}"
      puts "  Fund Investor Investments: #{FundInvestorInvestment.count}"
      puts "  Fund Distributions: #{FundDistribution.count}"
      puts "  Fund Investor Transactions: #{FundInvestorTransaction.count}"
      puts "  Documents: #{Document.count}"

    rescue => e
      puts "\n❌ Import failed: #{e.message}"
      puts e.backtrace.first(5).join("\n")
      exit 1
    end
  end

  desc "Import specific entity from PostgreSQL friale database"
  task :friale_entity, [ :entity ] => :environment do |task, args|
    entity = args[:entity]

    unless entity
      puts "Please specify an entity to import:"
      puts "  rake import:friale_entity[users]"
      puts "  rake import:friale_entity[firm_accounts]"
      puts "  rake import:friale_entity[funds]"
      puts "  etc."
      exit 1
    end

    importer = Importers::FrialeDbImporter.new
    method_name = "generate_#{entity}!"

    if importer.respond_to?(method_name, true)
      puts "Importing #{entity}..."
      importer.send(method_name)
      puts "✅ #{entity.capitalize} import completed!"
    else
      puts "❌ Unknown entity: #{entity}"
      puts "Available entities: users, locations, firm_accounts, funds, companies, company_notes, investor_accounts, positions, assets, marks, bank_accounts, fund_investor_investments, fund_distributions, fund_investor_transactions, documents"
      exit 1
    end
  end
end
