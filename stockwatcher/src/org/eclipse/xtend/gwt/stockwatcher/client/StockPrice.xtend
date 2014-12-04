package org.eclipse.xtend.gwt.stockwatcher.client

import org.eclipse.xtend.lib.annotations.Accessors

class StockPrice {
	@Accessors String symbol;
	@Accessors double price;
	@Accessors double change;

	new(String symbol, double price, double change) {
		this.symbol = symbol
		this.price = price
		this.change = change
	}

	def getChangePercent() {
		100.0 * change / price;
	}
}
