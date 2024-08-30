CREATE TABLE {view_name}
(
    chain String,
    network String,
    chain_id Int32,
    dt Date,
    to_address FixedString(42),
    count_transactions_to AggregateFunction(count),
    count_transactions_to_success AggregateFunction(count),
    count_blocks_to AggregateFunction(uniq, UInt64),
    count_blocks_to_success AggregateFunction(uniq, UInt64),
    sum_gas_used_to AggregateFunction(sum, UInt128),
    sum_gas_used_to_success AggregateFunction(sum, UInt128),
    count_unique_from_addresses_to AggregateFunction(uniq, FixedString(42)),
    count_unique_from_addresses_to_success AggregateFunction(uniq, FixedString(42)),
    sum_eth_gas_fees_to AggregateFunction(sum, Float64),
    sum_eth_gas_fees_to_success AggregateFunction(sum, Float64),
    sum_l1_fee_contrib_eth_gas_fees_to AggregateFunction(sum, Float64),
    sum_l1_fee_contrib_eth_gas_fees_to_success AggregateFunction(sum, Float64),
    sum_l2_fee_contrib_eth_gas_fees_to AggregateFunction(sum, Float64),
    sum_l2_fee_contrib_eth_gas_fees_to_success AggregateFunction(sum, Float64),
    {# sum_l2_base_contrib_eth_gas_fees_to AggregateFunction(sum, Float64),
    sum_l2_base_contrib_eth_gas_fees_to_success AggregateFunction(sum, Float64), #}
    {# sum_l2_priority_contrib_eth_gas_fees_to AggregateFunction(sum, Float64),
    sum_l2_priority_contrib_eth_gas_fees_to_success AggregateFunction(sum, Float64), #}
    sum_input_bytes_to AggregateFunction(sum, Int64),
    sum_input_bytes_to_success AggregateFunction(sum, Int64),
    avg_l2_gas_price_gwei AggregateFunction(avg, Float64),
    {# avg_l2_base_fee_gas_price_gwei AggregateFunction(avg, Float64),
    avg_l2_priority_fee_gas_price_gwei AggregateFunction(avg, Float64), #}
    avg_l1_gas_price_gwei AggregateFunction(avg, Float64),
)
ENGINE = AggregatingMergeTree()
ORDER BY (chain, network, chain_id, dt, to_address)