import 'dart:async';
import 'package:dapp/services/ethereum_service.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class EventListenerManager {
  final EthereumService _ethereumService;
  final Map<String, List<StreamSubscription<FilterEvent>>> _listeners = {};

  EventListenerManager(this._ethereumService);

  void listenToGroupCreatedEvents(String contractAddress,
      Function(String, List<EthereumAddress>, String) handler) async {
    StreamSubscription<FilterEvent> subscription = await _ethereumService
        .listenToGroupCreatedEvents(contractAddress, handler);
    _listeners.putIfAbsent(contractAddress, () => []).add(subscription);
    debugPrint(
        '[Splidapp.event_listener_manager] listenToGroupCreatedEvents listener activated');
  }

  void listenToGroupDisbandedEvents(String contractAddress,
      Function(String, List<EthereumAddress>, String) handler) async {
    StreamSubscription<FilterEvent> subscription = await _ethereumService
        .listenToGroupDisbandedEvents(contractAddress, handler);
    _listeners.putIfAbsent(contractAddress, () => []).add(subscription);
    debugPrint(
        '[Splidapp.event_listener_manager] listenToGroupDisbandedEvents listener activated');
  }

  void listenToInitiateTransactionEvents(
      String contractAddress, Function(List<dynamic>) handler) async {
    StreamSubscription<FilterEvent> subscription = await _ethereumService
        .listenToInitiateTransactionEvents(contractAddress, handler);
    _listeners.putIfAbsent(contractAddress, () => []).add(subscription);
    debugPrint(
        '[Splidapp.event_listener_manager] listenToInitiateTransactionEvents listener activated');
  }

  void listenToApprovedTransactionEvents(
      String contractAddress, Function(List<dynamic>) handler) async {
    StreamSubscription<FilterEvent> subscription = await _ethereumService
        .listenToApprovedTransactionEvents(contractAddress, handler);
    _listeners.putIfAbsent(contractAddress, () => []).add(subscription);
    debugPrint(
        '[Splidapp.event_listener_manager] listenToApprovedTransactionEvents listener activated');
  }

  void listenToDeclinedTransactionEvents(
      String contractAddress, Function(List<dynamic>) handler) async {
    StreamSubscription<FilterEvent> subscription = await _ethereumService
        .listenToDeclinedTransactionEvents(contractAddress, handler);
    _listeners.putIfAbsent(contractAddress, () => []).add(subscription);
    debugPrint(
        '[Splidapp.event_listener_manager] listenToDeclinedTransactionEvents listener activated');
  }

  void listenToExecutedTransactionEvents(
      String contractAddress, Function(List<dynamic>) handler) async {
    StreamSubscription<FilterEvent> subscription = await _ethereumService
        .listenToExecutedTransactionEvents(contractAddress, handler);
    _listeners.putIfAbsent(contractAddress, () => []).add(subscription);
    debugPrint(
        '[Splidapp.event_listener_manager] listenToExecutedTransactionEvents listener activated');
  }

  void listenToEscrowRegisteredEvents(
      Function(String, EthereumAddress, EthereumAddress) handler) {
    String escrowFactoryAddress = _ethereumService.factoryContractAddress;
    StreamSubscription<FilterEvent> subscription =
        _ethereumService.listenToEscrowRegisteredEvents(handler);
    _listeners.putIfAbsent(escrowFactoryAddress, () => []).add(subscription);
    debugPrint(
        '[Splidapp.event_listener_manager] listenToEscrowRegisteredEvents listener activated');
  }

  void listenToEscrowDeregisteredEvents(
      Function(String, EthereumAddress, EthereumAddress) handler) {
    String escrowFactoryAddress = _ethereumService.factoryContractAddress;
    StreamSubscription<FilterEvent> subscription =
        _ethereumService.listenToEscrowDeregisteredEvents(handler);
    _listeners.putIfAbsent(escrowFactoryAddress, () => []).add(subscription);
    debugPrint(
        '[Splidapp.event_listener_manager] listenToEscrowDeregisteredEvents listener activated');
  }

  void stopListeningForContract(String contractAddress) async {
    List<StreamSubscription<FilterEvent>> subscriptionList =
        _listeners.putIfAbsent(contractAddress, () => []);
    if (subscriptionList.isNotEmpty) {
      for (StreamSubscription<FilterEvent> subscription in subscriptionList) {
        try {
          //TODO: Need to find the root of asynchronous error, delay seem to be dealing it for now
          await Future.delayed(const Duration(milliseconds: 100));
          await subscription.cancel();
        } catch (e) {
          debugPrint(
              '[Splidapp.event_listener_manager] Error cancelling listener for $contractAddress: $e');
        }
      }
      _listeners.remove(contractAddress);
      debugPrint(
          '[Splidapp.event_listener_manager] $contractAddress listener deactivated');
    }
  }
}
