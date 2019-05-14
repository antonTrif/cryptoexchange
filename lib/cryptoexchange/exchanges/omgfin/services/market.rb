module Cryptoexchange::Exchanges
  module Omgfin
    module Services
      class Market < Cryptoexchange::Services::Market
        class << self
          def supports_individual_ticker_query?
            false
          end
        end

        def fetch
          output = super(ticker_url)
          adapt_all(output)
        end

        def ticker_url
          "#{Cryptoexchange::Exchanges::Omgfin::Market::API_URL}/ticker/24hr"
        end

        def adapt_all(output)
          output.map do |pair|
            base, target = pair['symbol'].split('_')
            market_pair = Cryptoexchange::Models::MarketPair.new(
                            base: base,
                            target: target,
                            market: Omgfin::Market::NAME
                          )
            adapt(market_pair, pair)
          end
        end

        def adapt(market_pair, output)
          ticker = Cryptoexchange::Models::Ticker.new
          ticker.base = market_pair.base
          ticker.target = market_pair.target
          ticker.market = Omgfin::Market::NAME
          ticker.last = NumericHelper.to_d(output['lastPrice'].to_f)
          ticker.bid = NumericHelper.to_d(output['bidPrice'].to_f)
          ticker.ask = NumericHelper.to_d(output['askPrice'].to_f)
          ticker.high = NumericHelper.to_d(output['highPrice'].to_f)
          ticker.low = NumericHelper.to_d(output['lowPrice'].to_f)
          ticker.volume = NumericHelper.to_d(output['volume']).to_f
          ticker.timestamp = nil
          ticker.payload = output
          ticker
        end
      end
    end
  end
end
