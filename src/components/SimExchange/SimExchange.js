import React, { Component } from 'react';
import { Col, Row } from 'antd';
import { withRouter } from 'react-router';

import TopBar from './TopBar';
import Trades from './Trade/Trades';
import Wallet from './Wallet';
import OrdersPositionsFills from './OrdersPositionsFills/Index';

import '../../less/SimExchange.less';
import OrderBook from './OrderBook/Orders';
import TradeHistory from './TradeHistory/Trades';
import TradeChart from './TradeChart/Chart';

class SimExchange extends Component {
  componentDidMount() {
    if (!this.props.contracts) {
      this.props.getContracts();
    }
  }

  componentDidUpdate(prevProps) {
    if (this.props.contracts && !this.props.contract) {
      this.props.selectContract(this.props.contracts[0]);
    }
  }

  render() {
    const { asks, bids, contract, contracts } = this.props;

    if (!this.props.shouldRender) {
      return (
        <div
          className="text-center"
          style={{ fontSize: '18px', padding: '4em' }}
        >
          <strong>Coming soon...</strong>
        </div>
      );
    }

    return (
      <div style={{ padding: '15px' }} id="sim-exchange">
        <Row
          type="flex"
          justify="space-between"
          className="sim-ex-container contract-container"
        >
          <TopBar
            contract={contract}
            contracts={contracts}
            onSelectContract={this.props.selectContract}
          />
        </Row>
        <Row type="flex" justify="space-between">
          <Col lg={6} xl={5}>
            <div className="column-container">
              <Wallet {...this.props} />
              <Trades {...this.props} asks={asks} bids={bids} />
            </div>
          </Col>
          <Col lg={5} xl={5}>
            <div className="column-container">
              <OrderBook />
            </div>
          </Col>
          <Col lg={7} xl={9}>
            <div className="column-container">
              <TradeChart />
              <OrdersPositionsFills {...this.props} />
            </div>
          </Col>
          <Col lg={6} xl={5}>
            <div className="column-container" style={{ paddingRight: '0' }}>
              <TradeHistory />
            </div>
          </Col>
        </Row>
      </div>
    );
  }
}

export default withRouter(SimExchange);
