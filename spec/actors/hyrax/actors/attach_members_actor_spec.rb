RSpec.describe Hyrax::Actors::AttachMembersActor do
  let(:ability) { ::Ability.new(depositor) }
  let(:env) { Hyrax::Actors::Environment.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:depositor) { create(:user) }
  let(:work) { create(:work) }
  let(:attributes) { HashWithIndifferentAccess.new(work_members_attributes: { '0' => { id: id } }) }

  subject(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end
    stack.build(terminator)
  end

  describe "#update" do
    subject { middleware.update(env) }

    before do
      work.ordered_members << existing_child_work
    end
    let(:existing_child_work) { create(:work) }
    let(:id) { existing_child_work.id }

    context "without useful attributes" do
      let(:attributes) { {} }

      it { is_expected.to be true }
    end

    context "when the id already exists in the members" do
      it "does nothing" do
        expect { subject }.not_to change { env.curation_concern.ordered_members.to_a }
      end

      context "and the _destroy flag is set" do
        let(:attributes) { HashWithIndifferentAccess.new(work_members_attributes: { '0' => { id: id, _destroy: 'true' } }) }

        it "removes from the member and the ordered members" do
          expect { subject }.to change { env.curation_concern.ordered_members.to_a }
          expect(env.curation_concern.ordered_member_ids).not_to include(existing_child_work.id)
          expect(env.curation_concern.member_ids).not_to include(existing_child_work.id)
        end
      end
    end

    context "when the id does not exist in the members" do
      let(:another_work) { create(:work) }
      let(:id) { another_work.id }

      context "and I can edit that object" do
        let(:another_work) { create(:work, user: depositor) }

        it "is added to the ordered members" do
          expect { subject }.to change { env.curation_concern.ordered_members.to_a }
          expect(env.curation_concern.ordered_member_ids).to include(existing_child_work.id, another_work.id)
        end
      end

      context "and I can not edit that object" do
        it "does nothing" do
          expect { subject }.not_to change { env.curation_concern.ordered_members.to_a }
        end
      end
    end

    context 'when using a valkyrie resource' do
      let(:work) { create(:work).valkyrie_resource }

      before { work.member_ids << Valkyrie::ID.new(existing_child_work.id) }

      context "when the _destroy flag is set" do
        let(:attributes) { HashWithIndifferentAccess.new(work_members_attributes: { '0' => { id: id, _destroy: 'true' } }) }

        it "removes from the members" do
          expect { middleware.update(env) }
            .to change { env.curation_concern.member_ids }
            .from([Valkyrie::ID.new(existing_child_work.id)])
            .to be_empty
        end
      end

      context 'when adding a duplicate member' do
        it "does nothing" do
          expect { middleware.update(env) }
            .not_to change { env.curation_concern.member_ids }
        end
      end

      context 'when adding a new member' do
        let(:another_work) { create(:work, user: depositor) }
        let(:id) { another_work.id }

        it 'adds successfully' do
          expect { middleware.update(env) }
            .to change { env.curation_concern.member_ids }
            .from([Valkyrie::ID.new(existing_child_work.id)])
            .to [Valkyrie::ID.new(existing_child_work.id),
                 Valkyrie::ID.new(another_work.id)]
        end

        context 'and the ability cannot edit' do
          let(:another_work) { create(:work) }

          it "does nothing" do
            expect { middleware.update(env) }
              .not_to change { env.curation_concern.member_ids }
          end
        end
      end
    end
  end
end
