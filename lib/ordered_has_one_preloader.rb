require "ordered_has_one_preloader/version"
require "active_record"

module OrderedHasOnePreloader
  private

  def build_scope
    klass.
      joins(join_node(super)).
      tap{|relation| relation.bind_values += ordering_subquery(super).bind_values }
  end

  def ordering_subquery(relation)
    relation.
      except(:select, :order).
      select(klass.arel_table[:id]).
      where(model.arel_table[model.primary_key].eq(klass.arel_table[reflection.foreign_key])).
      merge(reflection_scope).
      limit(1)
  end

  def join_subquery(relation)
    model.
      unscoped.
      where(model.primary_key => owners).
      select(ordering_subquery(relation).arel.as('id')).
      arel.
      as("#{model.table_name}_has_one_#{klass.table_name.singularize}")
  end

  def join_node(relation)
    Arel::Nodes::InnerJoin.new(
      join_subquery(relation),
      Arel::Nodes::On.new(klass.arel_table[:id].eq(join_subquery(relation)[:id]))
    )
  end
end

ActiveRecord::Associations::Preloader::HasOne.send(:prepend, OrderedHasOnePreloader)
