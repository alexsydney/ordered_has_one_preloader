require "ordered_has_one_preloader/version"
require "active_record"

module OrderedHasOnePreloader
  private

  def build_scope
    super.except(:order).joins(join_clause)
  end

  def order_values
    preload_scope.values[:order] || reflection_scope.values[:order]
  end

  def ordering_subquery
    klass.
      arel_table.
      project(:id).
      where(model.arel_table[model.primary_key].eq(klass.arel_table[reflection.foreign_key])).
      order(order_values).
      take(1).
      as('id')
  end

  def join_subquery
    model.
      where(model.primary_key => owners).
      select(ordering_subquery).
      arel.
      as("#{model.table_name}_subquery")
  end

  def join_clause
    Arel::Nodes::InnerJoin.new(
      join_subquery,
      Arel::Nodes::On.new(klass.arel_table[:id].eq(join_subquery[:id]))
    )
  end
end

ActiveRecord::Associations::Preloader::HasOne.send(:prepend, OrderedHasOnePreloader)
